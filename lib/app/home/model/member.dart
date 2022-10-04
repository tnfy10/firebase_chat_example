import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String? email;
  final String? nickname;
  final String? profileImg;
  final String? statusMessage;
  final List<String>? friendUidList;

  Member(
      {required this.email,
      required this.nickname,
      required this.profileImg,
      required this.statusMessage,
      required this.friendUidList});

  factory Member.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Member(
        email: data?['email'],
        nickname: data?['nickname'],
        profileImg: data?['profileImg'],
        statusMessage: data?['statusMessage'],
        friendUidList: data?['friendUidList'] is Iterable
            ? List.from(data?['friendUidList'])
            : null);
  }

  Map<String, dynamic> toFirestore() => {
        if (email != null) "email": email,
        if (nickname != null) "nickname": nickname,
        if (profileImg != null) "profileImg": profileImg,
        if (statusMessage != null) "statusMessage": statusMessage,
        if (friendUidList != null) "friendUidList": friendUidList
      };
}
