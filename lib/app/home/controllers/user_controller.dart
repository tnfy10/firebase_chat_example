import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/login/bindings/login_binding.dart';
import 'package:firebase_chat_example/app/login/screens/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../const/firestore_collection.dart';
import '../model/member.dart';

class UserController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Rx<Member> member = Member().obs;
  RxMap friendMap = <String, Member>{}.obs;
  RxBool isValidEmail = false.obs;

  var errMsg = "";

  @override
  void onInit() {
    super.onInit();
    receiveMemberData();
  }

  void receiveMemberData() async {
    try {
      db
          .collection(FirestoreCollection.member)
          .doc(auth.currentUser!.uid)
          .snapshots()
          .listen((event) {
        member.value = Member.fromFirestore(event);
        for (final uid in member.value.friendUidList ?? []) {
          db.collection(FirestoreCollection.member).doc(uid).get().then((value) {
            friendMap[uid] = Member.fromFirestore(value);
          });
        }
        member.refresh();
      }).onError((e) {
        throw (e);
      });
    } catch (e) {
      debugPrint("UserController::getMemberData:member 데이터 로드 에러");
      debugPrint("UserController::getMemberData:${e.toString()}");
      auth.signOut().then((_) {
        Get.offAll(LoginScreen(), binding: LoginBinding());
      });
    }
  }

  Future<bool> addFriend(String email) async {
    final friendRef =
        await db.collection(FirestoreCollection.member).where("email", isEqualTo: email).get();

    if (auth.currentUser?.email == email) {
      errMsg = "본인을 친구로 추가할 수 없습니다.";
      return false;
    }

    if (friendRef.size == 0) {
      errMsg = "해당 이메일을 가진 사용자를 찾을 수 없습니다.";
      return false;
    }

    final friendUid = friendRef.docs[0].id;

    if (member.value.friendUidList?.contains(friendUid) ?? true) {
      errMsg = "이미 추가된 사용자입니다.";
      return false;
    }

    db.collection(FirestoreCollection.member).doc(auth.currentUser!.uid).update({
      "friendUidList": FieldValue.arrayUnion([friendUid])
    });

    db.collection(FirestoreCollection.member).doc(friendUid).get().then((value) {
      friendMap[friendUid] = Member.fromFirestore(value);
    });

    return true;
  }

  void updateProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      final storageRef = FirebaseStorage.instance.ref();

      if (image?.path == null) {
        debugPrint('UserController::updateProfileImage::이미지 경로가 null임.');
        return;
      }

      final imageRef = storageRef.child('profileImg/${auth.currentUser!.uid}');
      File file = File(image!.path);
      await imageRef.putFile(file);
      final imgUrl = await imageRef.getDownloadURL();
      final memberRef = db.collection(FirestoreCollection.member).doc(auth.currentUser!.uid);
      await memberRef.update({'profileImg': imgUrl});
    } catch (e) {
      debugPrint('UserController::updateProfileImage::error:${e.toString()}');
    }
  }

  void updateNickname(String nickname) async {
    try {
      final memberRef = db.collection(FirestoreCollection.member).doc(auth.currentUser!.uid);
      await memberRef.update({'nickname': nickname});
    } catch (e) {
      debugPrint('UserController::updateNickname::error:${e.toString()}');
    }
  }

  void updateStatusMessage(String statusMessage) async {
    try {
      final memberRef = db.collection(FirestoreCollection.member).doc(auth.currentUser!.uid);
      await memberRef.update({'statusMessage': statusMessage});
    } catch (e) {
      debugPrint('UserController::updateNickname::error:${e.toString()}');
    }
  }

  void updatePassword() {}

  void withdrawal() async {
    await auth.currentUser?.delete();
    auth.signOut().then((_) {
      Get.offAll(LoginScreen(), binding: LoginBinding());
    });
  }
}
