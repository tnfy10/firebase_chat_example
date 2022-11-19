import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:get/get.dart';

import '../model/chat.dart';
import '../model/room.dart';

class ChatRoomListController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  RxList<Room> chatRoomList = <Room>[].obs;

  @override
  void onInit() {
    super.onInit();
    db
        .collection(FirestoreCollection.chatRoom)
        .snapshots()
        .listen((event) {
          fetchRoomList(event.docs);
    });
  }

  void fetchRoomList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    chatRoomList.clear();

    for (var doc in docs) {
      List uidList = doc.data()['uidList'];
      if (!uidList.contains(auth.currentUser?.uid)) {
        continue;
      }

      var room = Room();
      room.roomCode = doc.id;
      room.uidList = uidList;
      for (var i = 0; i < room.uidList.length; i++) {
        var member = await db.collection(FirestoreCollection.member).doc(room.uidList[i]).get();
        room.roomName += member['nickname'];
        if (i != room.uidList.length - 1) {
          room.roomName += ", ";
        }
      }

      final chatRef = await db
          .collection(FirestoreCollection.chat)
          .where('roomCode', isEqualTo: doc.id)
          .orderBy('sendMillisecondEpoch', descending: true)
          .get();

      if (chatRef.docs.isNotEmpty) {
        final chat = Chat.fromFirestore(chatRef.docs[0]);
        room.recentMsg = convertChatText(chat);
        chatRoomList.add(room);
      }
    }
    chatRoomList.refresh();
  }

  String convertChatText(Chat chat) {
    switch (chat.kind) {
      case SendKind.image:
        return '사진';
      case SendKind.file:
        return '파일';
      default:
        return chat.text ?? '';
    }
  }
}
