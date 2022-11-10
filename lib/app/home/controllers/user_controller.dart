import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/login/bindings/login_binding.dart';
import 'package:firebase_chat_example/app/login/screens/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../const/firestore_collection.dart';
import '../model/member.dart';

class UserController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Rx<Member> member = Member().obs;

  RxList<Member> friendList = <Member>[].obs;
  RxBool isLoading = false.obs;

  RxBool isValidEmail = false.obs;

  var errMsg = "";

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  void initData() async {
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
      member.value = Member.fromFirestore(doc);
      member.refresh();
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
      for (final uid in member.value.friendUidList ?? []) {
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

    if (member.value.friendUidList?.contains(friendUid) ?? true) {
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

  Future<void> updateProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      final storageRef = FirebaseStorage.instance.ref();

      if (image?.path == null) {
        return Future.error('UserController::updateProfileImage::이미지 경로가 null임.');
      }

      final imageRef = storageRef.child(image!.path);
      File file = File(image.path);
      await imageRef.putFile(file);
      final imgUrl = await imageRef.getDownloadURL();
      final memberRef = db.collection(FirestoreCollection.member).doc(auth.currentUser!.uid);
      await memberRef.update({'profileImg': imgUrl});
      getMemberData();
    } catch (e) {
      return Future.error('UserController::updateProfileImage::error:${e.toString()}');
    }
  }

  Future<void> updateNickname() async {

  }
}
