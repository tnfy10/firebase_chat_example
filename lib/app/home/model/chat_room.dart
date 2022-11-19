import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String? roomName;
  final String? recentMsg;
  final List? uidList;

  ChatRoom(
      {required this.roomName,
      required this.recentMsg,
      required this.uidList});

  factory ChatRoom.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return ChatRoom(
        roomName: data?['roomName'],
        recentMsg: data?['recentMsg'],
        uidList: data?['uidList']);
  }

  Map<String, dynamic> toFirestore() => {
        if (roomName != null) "roomName": roomName,
        if (recentMsg != null) "recentMsg": recentMsg,
        if (uidList != null) "uidList": uidList
      };
}
