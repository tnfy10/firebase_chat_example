import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String? code;
  final List<String>? uidList;
  final List<String>? chatList;

  ChatRoom({required this.code, required this.uidList, required this.chatList});

  factory ChatRoom.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return ChatRoom(
        code: data?['code'],
        uidList:
            data?['uidList'] is Iterable ? List.from(data?['uidList']) : null,
        chatList: data?['chatList'] is Iterable
            ? List.from(data?['chatList'])
            : null);
  }

  Map<String, dynamic> toFirestore() =>
      {"code": code, "uidList": uidList, "chatList": chatList};
}
