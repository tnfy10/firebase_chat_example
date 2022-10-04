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
  final String? senderUid;
  final String? sendDateTime;
  final String? text;
  final SendKind? kind;

  Chat(
      {required this.senderUid,
      required this.sendDateTime,
      required this.text,
      required this.kind});

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Chat(
        senderUid: data?['senderUid'],
        sendDateTime: data?['sendDateTime'],
        text: data?['text'],
        kind: SendKind.fromString(data?['kind']));
  }

  Map<String, dynamic> toFirestore() => {
        "senderUid": senderUid,
        "sendDateTime": sendDateTime,
        "text": text,
        "kind": describeEnum(kind!)
      };
}
