import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/home/screens/chat_room_screen.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../model/member.dart';
import '../model/room.dart';
import 'chat_controller.dart';

class ChatRoomController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final memberList = <Member>[];

  Map<String, String?> memberProfileImgMap = {};

  RxBool isLoading = false.obs;

  String? roomCode;

  Future<void> enterChatRoom(Room room) async {
    roomCode = room.roomCode;
    await _fetchMemberList(room.uidList);
    await _fetchMemberProfileImg();
    Get.to(() => ChatRoomScreen(), binding: BindingsBuilder(() {
      Get.put(ChatController());
    }));
  }

  Future<void> _fetchMemberList(List uidList) async {
    memberList.clear();
    for (var uid in uidList) {
      var member = await db.collection(FirestoreCollection.member).doc(uid).get();
      memberList.add(Member.fromFirestore(member));
    }
  }

  Future<void> startOneOnOneChat(String email) async {
    memberList.clear();
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::getChatRoomList::Current User uid is null.");
    }

    final memberRef =
        await db.collection(FirestoreCollection.member).where("email", isEqualTo: email).get();

    if (memberRef.docs.isEmpty) {
      return Future.error("ChatController::getChatRoomList::User not found");
    }

    final friendUid = memberRef.docs[0].id;
    final uidList = [auth.currentUser!.uid, friendUid];

    memberList.add(Member.fromFirestore(memberRef.docs[0]));

    final chatRoomRef = await db
        .collection(FirestoreCollection.chatRoom)
        .where("uidList", arrayContainsAny: uidList)
        .get();

    if (chatRoomRef.docs.isNotEmpty) {
      roomCode = chatRoomRef.docs[0].id;
      await _fetchMemberProfileImg();
      return;
    }

    await _createOneOnOneChatRoom(friendUid);
  }

  Future<void> _createOneOnOneChatRoom(String friendUid) async {
    if (auth.currentUser?.uid == null) {
      return Future.error("ChatController::createChatRoom::Current User uid is null.");
    }

    final data = {
      "uidList": [auth.currentUser!.uid, friendUid]
    };

    final uuid = const Uuid().v1();

    await db.collection(FirestoreCollection.chatRoom).doc(uuid).set(data, SetOptions(merge: true));

    roomCode = uuid;
    await _fetchMemberProfileImg();
  }

  Future<void> _fetchMemberProfileImg() async {
    memberProfileImgMap.clear();

    final chatRoomData = await db.collection(FirestoreCollection.chatRoom).doc(roomCode).get();
    final uidList = chatRoomData.data()!["uidList"];

    for (var uid in uidList) {
      db.collection(FirestoreCollection.member).doc(uid).get().then((value) {
        final member = Member.fromFirestore(value);
        memberProfileImgMap[uid] = member.profileImg ?? '';
      });
    }
  }
}
