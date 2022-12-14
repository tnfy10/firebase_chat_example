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
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../themes/color_scheme.dart';
import '../model/chat.dart';
import '../model/image_data.dart';
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
      debugPrint('ChatController::sendImage::????????? ????????? ?????????.');
      return;
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: '?????????',
            toolbarColor: lightColorScheme.primaryContainer,
            toolbarWidgetColor: lightColorScheme.primary,
            backgroundColor: lightColorScheme.surfaceVariant,
            activeControlsWidgetColor: lightColorScheme.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: '?????????',
        )
      ],
    );

    if (croppedFile == null) {
      debugPrint('ChatController::sendImage::???????????? ?????????.');
      return;
    }

    Get.snackbar('????????? ?????? ???', image.name);

    const uuid = Uuid();
    final imageRef = storageRef.child('$roomCode/${uuid.v1()}');
    File file = File(croppedFile.path);
    await imageRef.putFile(file);
    final imgUrl = await imageRef.getDownloadURL();

    final bytes = await croppedFile.readAsBytes();
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
      Get.snackbar('????????? ?????? ??????', image.name);
    }).catchError((e) {
      debugPrint('ChatController::sendImage::error:${e.toString()}');
      Get.snackbar('????????? ?????? ??????', image.name);
    });
  }

  Future<void> sendFile() async {
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::sendMessage::User uid is null.");
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    final storageRef = FirebaseStorage.instance.ref();

    if (result == null) {
      debugPrint('ChatController::sendFile::?????? ????????? null???.');
      return;
    }

    Get.snackbar('?????? ?????? ???', result.files.single.name);

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
      Get.snackbar('?????? ?????? ??????', result.files.single.name);
    }).catchError((e) {
      debugPrint('ChatController::sendFile::error:${e.toString()}');
      Get.snackbar('?????? ?????? ??????', result.files.single.name);
    });
  }

  Future<ImageData> getImageData(String imgUrl) async {
    isLoading.value = true;
    final ref = FirebaseStorage.instance.refFromURL(imgUrl);
    final metadata = await ref.getMetadata();
    final mByteValue =
        metadata.size != null ? (metadata.size! / 1024 / 1024).toStringAsFixed(2) : 0;
    final data = await ref.getData();
    final image = await decodeImageFromList(data!);
    isLoading.value = false;
    return ImageData(
        kind: metadata.contentType!,
        mByteValue: '${mByteValue}MB',
        resolution: '${image.width}X${image.height}');
  }
}
