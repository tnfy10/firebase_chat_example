import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/login/bindings/login_binding.dart';
import 'package:firebase_chat_example/app/login/screens/login_screen.dart';
import 'package:firebase_chat_example/themes/color_scheme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../const/firestore_collection.dart';
import '../model/member.dart';

class UserController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Rx<Member> member = Member().obs;
  RxMap friendMap = <String, Member>{}.obs;
  RxBool isValidEmail = false.obs;
  RxBool isLoading = false.obs;

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
        debugPrint('UserController::updateProfileImage::이미지 선택이 취소됨.');
        return;
      }

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: '자르기',
              toolbarColor: lightColorScheme.primaryContainer,
              toolbarWidgetColor: lightColorScheme.primary,
              backgroundColor: lightColorScheme.surfaceVariant,
              activeControlsWidgetColor: lightColorScheme.primary,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: '자르기',
          )
        ],
      );

      if (croppedFile == null) {
        debugPrint('ChatController::sendImage::자르기가 취소됨.');
        return;
      }

      final imageRef = storageRef.child('profileImg/${auth.currentUser!.uid}');
      File file = File(croppedFile!.path);
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

  void updatePassword(String oldPwd, String newPwd,
      {required Function() onComplete, required Function(String) onError}) async {
    isLoading.value = true;
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: auth.currentUser!.email!,
        password: oldPwd,
      );
      await credential.user?.updatePassword(newPwd);
      onComplete();
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      if (e.code == 'wrong-password') {
        onError('기존 비밀번호가 일치하지 않습니다.');
      } else {
        onError('비밀번호를 변경하는데 문제가 발생하였습니다.\n다시 시도해주세요.');
      }
    } catch (e) {
      debugPrint(e.toString());
      onError('비밀번호를 변경하는데 문제가 발생하였습니다.\n다시 시도해주세요.');
    } finally {
      isLoading.value = false;
    }
  }

  void withdrawal() async {
    await auth.currentUser?.delete();
    auth.signOut().then((_) {
      Get.offAll(LoginScreen(), binding: LoginBinding());
    });
  }
}
