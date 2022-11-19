import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:firebase_chat_example/utils/converter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../model/chat.dart';
import '../model/member.dart';

String currentRoomCode = '';

class ChatController extends GetxController {
  final String roomCode;
  final Map<String, Member> memberMap;
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  RxList<Chat> chatList = <Chat>[].obs;
  RxBool isLoading = false.obs;
  RxBool isOpenFileSend = false.obs;

  ChatController({required this.roomCode, required this.memberMap});

  @override
  void onInit() {
    super.onInit();
    receiveChatMessage();
    currentRoomCode = roomCode;
  }

  @override
  void onClose() {
    currentRoomCode = '';
    super.onClose();
  }

  void receiveChatMessage() {
    db
        .collection(FirestoreCollection.chat)
        .where("roomCode", isEqualTo: roomCode)
        .orderBy("sendMillisecondEpoch")
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          chatList.insert(0, Chat.fromFirestore(change.doc));
        }
      }
    });
  }

  Future<void> sendMessage(String msg) async {
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::sendMessage::User uid is null.");
    }

    final chat = Chat(
        roomCode: roomCode,
        senderUid: auth.currentUser?.uid,
        sendMillisecondEpoch: DateTime.now().millisecondsSinceEpoch,
        text: msg,
        kind: SendKind.message);

    await Future.wait([
      db.collection(FirestoreCollection.chat).doc().set(chat.toFirestore()),
      db
          .collection(FirestoreCollection.chatRoom)
          .doc(roomCode)
          .update({'recentMsg': convertChatText(chat)})
    ]);
  }

  Future<void> sendImage() async {
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::sendMessage::User uid is null.");
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    final storageRef = FirebaseStorage.instance.ref();

    if (image?.path == null) {
      debugPrint('ChatController::sendImage::이미지 경로가 null임.');
      return;
    }

    Get.snackbar('이미지 전송 중', image!.name);

    const uuid = Uuid();
    final imageRef = storageRef.child('$roomCode/${uuid.v1()}');
    File file = File(image.path);
    await imageRef.putFile(file);
    final imgUrl = await imageRef.getDownloadURL();

    final bytes = await image.readAsBytes();
    final imageByteSize = bytes.buffer.lengthInBytes;
    const limitByteSize = 10485760;

    final chat = Chat(
        roomCode: roomCode,
        senderUid: auth.currentUser?.uid,
        sendMillisecondEpoch: DateTime.now().millisecondsSinceEpoch,
        text: imgUrl,
        kind: imageByteSize < limitByteSize ? SendKind.image : SendKind.file,
        fileName: image.name);

    db.collection(FirestoreCollection.chat).doc().set(chat.toFirestore()).then((_) {
      db
          .collection(FirestoreCollection.chatRoom)
          .doc(roomCode)
          .update({'recentMsg': convertChatText(chat)});
      Get.snackbar('이미지 전송 완료', image.name);
    }).catchError((e) {
      debugPrint('ChatController::sendImage::error:${e.toString()}');
      Get.snackbar('이미지 전송 실패', image.name);
    });
  }

  Future<void> sendFile() async {
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::sendMessage::User uid is null.");
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    final storageRef = FirebaseStorage.instance.ref();

    if (result == null) {
      debugPrint('ChatController::sendFile::파일 경로가 null임.');
      return;
    }

    Get.snackbar('파일 전송 중', result.files.single.name);

    const uuid = Uuid();
    final fileRef = storageRef.child('$roomCode/${uuid.v1()}');
    File file = File(result.files.single.path!);
    await fileRef.putFile(file);
    final fileUrl = await fileRef.getDownloadURL();

    final chat = Chat(
        roomCode: roomCode,
        senderUid: auth.currentUser?.uid,
        sendMillisecondEpoch: DateTime.now().millisecondsSinceEpoch,
        text: fileUrl,
        kind: SendKind.file,
        fileName: result.files.single.name);

    db.collection(FirestoreCollection.chat).doc().set(chat.toFirestore()).then((_) {
      db
          .collection(FirestoreCollection.chatRoom)
          .doc(roomCode)
          .update({'recentMsg': convertChatText(chat)});
      Get.snackbar('파일 전송 완료', result.files.single.name);
    }).catchError((e) {
      debugPrint('ChatController::sendFile::error:${e.toString()}');
      Get.snackbar('파일 전송 실패', result.files.single.name);
    });
  }

  Future<void> downloadFile(String? url, String? fileName) async {
    if (url == null || fileName == null) {
      return;
    }

    final httpsReference = FirebaseStorage.instance.refFromURL(url);
    final filePath = await getDownloadPath();
    final file = File('$filePath/$fileName');
    final downloadTask = httpsReference.writeToFile(file);

    Get.snackbar('다운로드 시작', fileName);

    downloadTask.snapshotEvents.listen((taskSnapshot) {
      debugPrint(taskSnapshot.totalBytes.toString());
      switch (taskSnapshot.state) {
        case TaskState.running:
          debugPrint('다운로드 중');
          break;
        case TaskState.paused:
          debugPrint('일시정지');
          break;
        case TaskState.success:
          Get.snackbar('다운로드 완료', fileName);
          break;
        case TaskState.canceled:
          debugPrint('다운로드 취소');
          break;
        case TaskState.error:
          debugPrint('다운로드 에러');
          break;
      }
    });
  }

  Future<String> getDownloadPath() async {
    final completer = Completer<String>();
    try {
      if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        completer.complete(dir.path);
      } else {
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          completer.complete(directory.path);
        } else {
          completer.completeError('ChatController::getDownloadPath::error:다운로드 폴더가 존재하지 않음.');
        }
      }
    } catch (e) {
      completer.completeError('ChatController::getDownloadPath::error:${e.toString()}');
    }
    return completer.future;
  }
}
