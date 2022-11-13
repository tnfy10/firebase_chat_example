import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:get/get.dart';

import '../model/chat.dart';
import 'chat_room_controller.dart';

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  RxList<Chat> chatList = <Chat>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final chatRoomController = Get.find<ChatRoomController>();
    receiveChatMessage(chatRoomController.roomCode ?? "");
  }

  void receiveChatMessage(String roomCode) {
    db
        .collection(FirestoreCollection.chat)
        .where("roomCode", isEqualTo: roomCode)
        .orderBy("sendMillisecondEpoch")
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          chatList.add(Chat.fromFirestore(change.doc));
        }
      }
    });
  }

  Future<void> sendMessage(String roomCode, String msg) async {
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
}
