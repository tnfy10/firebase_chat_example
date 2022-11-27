import 'dart:async';

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

  Future<String> startOneOnOneChat(String friendUid) async {
    final completer = Completer<String>();

    try {
      if (auth.currentUser?.uid == null) {
        throw ("ChatController::getChatRoomList::Current User uid is null.");
      } else {
        final uidList = [auth.currentUser!.uid, friendUid];
        await fetchMemberList(uidList);

        uidList.sort();
        final chatRoomRef = await db
            .collection(FirestoreCollection.chatRoom)
            .where("uidList", arrayContains: auth.currentUser!.uid)
            .where("uidList", whereIn: [uidList])
            .get();

        if (chatRoomRef.docs.isEmpty) {
          final roomCode = await _createOneOnOneChatRoom(uidList);
          completer.complete(roomCode);
        } else {
          completer.complete(chatRoomRef.docs[0].id);
        }
      }
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<String> _createOneOnOneChatRoom(List uidList) async {
    final completer = Completer<String>();

    if (auth.currentUser?.uid == null) {
      completer.completeError("ChatController::createChatRoom::Current User uid is null.");
    } else {
      var roomName = '';

      for (var i = 0; i < uidList.length; i++) {
        roomName += memberMap[uidList[i]]!.nickname!;
        if (i != uidList.length - 1) {
          roomName += ', ';
        }
      }

      uidList.sort();
      final chatRoom = ChatRoom(roomName: roomName, recentMsg: '', uidList: uidList);
      final uuid = const Uuid().v1();

      try {
        await db.collection(FirestoreCollection.chatRoom).doc(uuid).set(chatRoom.toFirestore());
        completer.complete(uuid);
      } catch (e) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }
}
