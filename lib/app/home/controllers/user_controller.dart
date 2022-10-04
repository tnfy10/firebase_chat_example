import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/login/bindings/login_binding.dart';
import 'package:firebase_chat_example/app/login/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../const/firestore_collection.dart';
import '../model/member.dart';

class UserController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Member? member;

  RxList<Member> friendList = <Member>[].obs;
  RxBool isLoading = false.obs;

  RxBool isValidEmail = false.obs;

  var errMsg = "";

  void initDataLoad() async {
    isLoading.value = true;
    await getMemberData();
    await getFriendList();
    isLoading.value = false;
  }

  Future<void> getMemberData() async {
    try {
      final docRef =
          db.collection(FirestoreCollection.member).doc(auth.currentUser!.uid);
      final doc = await docRef.get();
      member = Member.fromFirestore(doc);
    } catch (e) {
      debugPrint("UserController::getMemberData:member 데이터 로드 에러");
      debugPrint("UserController::getMemberData:${e.toString()}");
      auth.signOut().then((_) {
        Get.offAll(LoginScreen(), binding: LoginBinding());
      });
    }
  }

  Future<void> getFriendList() async {
    List<Member> tempList = [];
    try {
      for (final uid in member?.friendUidList ?? []) {
        final docRef = db.collection(FirestoreCollection.member).doc(uid);
        final doc = await docRef.get();
        tempList.add(Member.fromFirestore(doc));
      }
    } catch (e) {
      debugPrint("UserController::getFriendList:friend 데이터 로드 에러");
      debugPrint("UserController::getFriendList:${e.toString()}");
    } finally {
      friendList.value = tempList;
    }
  }

  Future<bool> addFriend(String email) async {
    final friendRef = await db
        .collection(FirestoreCollection.member)
        .where("email", isEqualTo: email)
        .get();

    if (auth.currentUser?.email == email) {
      errMsg = "본인을 친구로 추가할 수 없습니다.";
      return false;
    }

    if (friendRef.size == 0) {
      errMsg = "해당 이메일을 가진 사용자를 찾을 수 없습니다.";
      return false;
    }

    final friendUid = friendRef.docs[0].reference.id;

    if (member?.friendUidList?.contains(friendUid) ?? true) {
      errMsg = "이미 추가된 사용자입니다.";
      return false;
    }

    final memberRef =
        db.collection(FirestoreCollection.member).doc(auth.currentUser!.uid);
    memberRef.update({
      "friendUidList": FieldValue.arrayUnion([friendUid])
    });

    await getFriendList();

    return true;
  }
}
