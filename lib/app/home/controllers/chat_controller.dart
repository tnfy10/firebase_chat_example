import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/chat.dart';
import '../model/member.dart';

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

    await db.collection(FirestoreCollection.chat).doc().set(chat.toFirestore());
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

    const uuid = Uuid();
    final imageRef = storageRef.child('$roomCode/${uuid.v1()}');
    File file = File(image!.path);
    await imageRef.putFile(file);
    final imgUrl = await imageRef.getDownloadURL();

    final chat = Chat(
        roomCode: roomCode,
        senderUid: auth.currentUser?.uid,
        sendMillisecondEpoch: DateTime.now().millisecondsSinceEpoch,
        text: imgUrl,
        kind: SendKind.image);

    await db.collection(FirestoreCollection.chat).doc().set(chat.toFirestore());
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

    await db.collection(FirestoreCollection.chat).doc().set(chat.toFirestore());
  }

  Future<void> downloadFile() async {

  }
}
