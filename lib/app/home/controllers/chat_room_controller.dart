import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../model/member.dart';
import '../model/chat_room.dart';

class ChatRoomController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final memberMap = <String, Member>{};

  RxMap chatRoomMap = <String, ChatRoom>{}.obs;

  late String currentRoomCode;

  @override
  void onInit() {
    super.onInit();
    db
        .collection(FirestoreCollection.chatRoom)
        .where('uidList', arrayContains: auth.currentUser?.uid)
        .snapshots()
        .listen((event) {
      for (var doc in event.docs) {
        chatRoomMap[doc.id] = ChatRoom.fromFirestore(doc);
      }
    });
  }

  Future<void> fetchMemberList(List uidList) async {
    memberMap.clear();
    for (var uid in uidList) {
      var member = await db.collection(FirestoreCollection.member).doc(uid).get();
      memberMap[uid] = Member.fromFirestore(member);
    }
  }

  Future<void> startOneOnOneChat(String friendUid) async {
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::getChatRoomList::Current User uid is null.");
    }

    final uidList = [auth.currentUser!.uid, friendUid];
    await fetchMemberList(uidList);

    final chatRoomRef = await db
        .collection(FirestoreCollection.chatRoom)
        .where("uidList", arrayContainsAny: uidList)
        .get();

    if (chatRoomRef.docs.isEmpty) {
      await _createOneOnOneChatRoom(uidList);
    } else {
      currentRoomCode = chatRoomRef.docs[0].id;
    }
  }

  Future<void> _createOneOnOneChatRoom(List uidList) async {
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::createChatRoom::Current User uid is null.");
    }

    var roomName = '';

    for (var i = 0; i < uidList.length; i++) {
      roomName += memberMap[uidList[i]]!.nickname!;
      if (i != uidList.length - 1) {
        roomName += ', ';
      }
    }

    final chatRoom = ChatRoom(roomName: roomName, recentMsg: '', uidList: uidList);
    final uuid = const Uuid().v1();

    await db.collection(FirestoreCollection.chatRoom).doc(uuid).set(chatRoom.toFirestore());
    currentRoomCode = uuid;
  }
}
