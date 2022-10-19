import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../model/chat.dart';

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  RxList<Chat> chatList = <Chat>[].obs;
  RxBool isLoading = false.obs;

  void receiveChatMessage(String roomCode) {
    final docRef = db.collection(FirestoreCollection.chat).where(
        "roomCode", isEqualTo: roomCode).get();
    // .listen(
    //   (event) {
    //     final chat = Chat.fromFirestore(event);
    //     chatList.add(chat);
    //   },
    //   onError: (error) => debugPrint(
    //       "ChatController::receiveChatMessage::Chat Message Listen failed: $error"),
    // );
  }

  Future<void> fetchChatHistory(String roomCode) async {
    final docRef = await db.collection(FirestoreCollection.chat).where(
        "roomCode", isEqualTo: roomCode).orderBy("sendMillisecondEpoch").get();
    
    for (var doc in docRef.docs) {
      chatList.add(Chat.fromFirestore(doc));
    }
  }

  Future<void> sendMessage(String roomCode, String msg) async {
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::sendMessage::User uid is null.");
    }

    final chat = Chat(
        roomCode: roomCode,
        senderUid: auth.currentUser?.uid,
        sendMillisecondEpoch: DateTime
            .now()
            .millisecondsSinceEpoch,
        text: msg,
        kind: SendKind.message);

    await db.collection(FirestoreCollection.chat).doc().set(chat.toFirestore());

    chatList.add(chat);
  }
}
