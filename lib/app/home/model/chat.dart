import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum SendKind {
  message,
  image,
  file;

  static SendKind fromString(String kind) {
    switch (kind) {
      case "message":
        return SendKind.message;
      case "image":
        return SendKind.image;
      case "file":
        return SendKind.file;
      default:
        return SendKind.message;
    }
  }
}

class Chat {
  final String? roomCode;
  final String? senderUid;
  final int? sendMillisecondEpoch;
  final String? text;
  final SendKind? kind;

  Chat(
      {required this.roomCode,
      required this.senderUid,
      required this.sendMillisecondEpoch,
      required this.text,
      required this.kind});

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Chat(
        roomCode: data?['roomCode'],
        senderUid: data?['senderUid'],
        sendMillisecondEpoch: data?['sendMillisecondEpoch'],
        text: data?['text'],
        kind: SendKind.fromString(data?['kind'] ?? "message"));
  }

  Map<String, dynamic> toFirestore() => {
        if (roomCode != null) "roomCode": roomCode,
        if (senderUid != null) "senderUid": senderUid,
        if (sendMillisecondEpoch != null)
          "sendMillisecondEpoch": sendMillisecondEpoch,
        if (text != null) "text": text,
        if (kind != null) "kind": describeEnum(kind!)
      };
}
