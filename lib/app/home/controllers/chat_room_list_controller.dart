import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:get/get.dart';

import '../model/room.dart';

class ChatRoomListController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  final List<String> _roomCodeList = [];
  RxList<Room> chatRoomList = <Room>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchRoomCodeList().then((_) {
      db
          .collection(FirestoreCollection.chat)
          .where('roomCode', whereIn: _roomCodeList)
          .snapshots()
          .listen((_) {
        fetchRoomList();
      });
    });
  }

  Future<void> _fetchRoomCodeList() async {
    _roomCodeList.clear();
    final chatRoomRef = await db
        .collection(FirestoreCollection.chatRoom)
        .where('uidList', arrayContains: auth.currentUser?.uid)
        .get();

    for (var doc in chatRoomRef.docs) {
      _roomCodeList.add(doc.id);
    }
  }

  void fetchRoomList() async {
    chatRoomList.clear();
    final chatRoomRef = await db
        .collection(FirestoreCollection.chatRoom)
        .where('uidList', arrayContains: auth.currentUser?.uid)
        .get();

    for (var doc in chatRoomRef.docs) {
      var room = Room();
      room.roomCode = doc.id;
      room.uidList = doc.data()['uidList'];
      for (var i = 0; i < room.uidList.length; i++) {
        var member = await db.collection(FirestoreCollection.member).doc(room.uidList[i]).get();
        room.roomName += member['nickname'];
        if (i != room.uidList.length - 1) {
          room.roomName += ", ";
        }
      }

      var chat = await db
          .collection(FirestoreCollection.chat)
          .where('roomCode', isEqualTo: doc.id)
          .orderBy('sendMillisecondEpoch', descending: true)
          .get();
      room.recentMsg = chat.docs[0].get('text') ?? '';
      chatRoomList.add(room);
    }
    chatRoomList.refresh();
  }
}
