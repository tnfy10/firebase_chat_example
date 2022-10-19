import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:uuid/uuid.dart';

import '../model/member.dart';

class ChatRoomController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Map<String, String?> memberProfileImgMap = {};
  RxBool isLoading = false.obs;

  String? chatRoomId;

  Future<void> startOneOnOneChat(String email) async {
    if (auth.currentUser?.uid == null) {
      return Future.error(
          "ChatController::getChatRoomList::Current User uid is null.");
    }

    final memberRef = await db.collection(FirestoreCollection.member).where("email", isEqualTo: email).get();

    if (memberRef.docs.isEmpty) {
      return Future.error(
          "ChatController::getChatRoomList::User not found");
    }

    final friendUid = memberRef.docs[0].id;

    final chatRoomRef = await db
        .collection(FirestoreCollection.chatRoom)
        .where("uidList", whereIn: [auth.currentUser!.uid, friendUid]).get();

    if (chatRoomRef.docs.isNotEmpty) {
      chatRoomId = chatRoomRef.docs[0].id;
      await _fetchMemberProfileImg();
      return;
    }

    await _createOneOnOneChatRoom(friendUid);
  }

  Future<void> _createOneOnOneChatRoom(String friendUid) async {
    if (auth.currentUser?.uid == null) {
      return Future.error(
          "ChatController::createChatRoom::Current User uid is null.");
    }

    final data = {
      "uidList": [auth.currentUser!.uid, friendUid]
    };

    final uuid = const Uuid().v1();

    await db
        .collection(FirestoreCollection.chatRoom)
        .doc(uuid)
        .set(data, SetOptions(merge: true));

    chatRoomId = uuid;
    await _fetchMemberProfileImg();
  }

  Future<void> _fetchMemberProfileImg() async {
    memberProfileImgMap.clear();

    final chatRoomData = await db.collection(FirestoreCollection.chatRoom).doc(chatRoomId).get();
    final uidList = chatRoomData.data()!["uidList"];

    for (var uid in uidList) {
      db.collection(FirestoreCollection.member).doc(uid).get().then((value) {
        final member = Member.fromFirestore(value);
        memberProfileImgMap[uid] = member.profileImg ?? '';
      });
    }
  }
}
