import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/const/firestore_collection.dart';
import 'package:get/get.dart';

import '../../home/model/member.dart';

class SignUpController extends GetxController {
  RxString email = "".obs;
  RxString password1 = "".obs;
  RxString password2 = "".obs;
  RxString nickname = "".obs;

  RxInt currentWidgetIdx = 0.obs;
  RxBool isValidEmail = true.obs;
  RxBool isValidPassword1 = true.obs;
  RxBool isValidPassword2 = true.obs;
  RxBool isValidNickname = true.obs;

  RxBool isLoading = false.obs;

  RxString emailErrorMsg = "".obs;
  RxString password1ErrorMsg = "".obs;
  RxString password2ErrorMsg = "".obs;
  RxString nicknameErrorMsg = "".obs;

  final firebaseAuth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Future<void> _checkValidEmail() async {
    if (email.value.isEmpty) {
      emailErrorMsg.value = "이메일을 입력해주세요";
      isValidEmail.value = false;
      return;
    }

    final regExp = RegExp(
        r"^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$");
    if (!regExp.hasMatch(email.value)) {
      emailErrorMsg.value = "이메일이 올바르지 않습니다.";
      isValidEmail.value = false;
      return;
    }

    final ref = await db
        .collection(FirestoreCollection.member)
        .where("email", isEqualTo: email.value)
        .get();
    if (ref.size != 0) {
      emailErrorMsg.value = "이미 존재하는 이메일 입니다.";
      isValidEmail.value = false;
      return;
    }

    isValidEmail.value = true;
  }

  bool _checkValidPassword() {
    if (password1.value.trim().isEmpty || password2.value.trim().isEmpty) {
      if (password1.value.trim().isEmpty) {
        password1ErrorMsg.value = "비밀번호를 입력해주세요.";
        isValidPassword1.value = false;
      } else {
        isValidPassword1.value = true;
      }
      if (password2.value.trim().isEmpty) {
        password2ErrorMsg.value = "비밀번호를 입력해주세요.";
        isValidPassword2.value = false;
      } else {
        isValidPassword2.value = true;
      }
      return false;
    }

    if (password1.value.trim() != password2.value.trim()) {
      password1ErrorMsg.value = "";
      password2ErrorMsg.value = "비밀번호가 일치하지 않습니다.";
      isValidPassword1.value = false;
      isValidPassword2.value = false;
      return false;
    }

    if (password2.value.length < 6) {
      password1ErrorMsg.value = "";
      password2ErrorMsg.value = "비밀번호가 최소 6자 이상이 되어야 합니다.";
      isValidPassword1.value = false;
      isValidPassword2.value = false;
      return false;
    }

    isValidPassword1.value = true;
    isValidPassword2.value = true;

    return true;
  }

  Future<void> _checkValidNickname() async {
    if (nickname.value.isEmpty) {
      isValidNickname.value = false;
      nicknameErrorMsg.value = "닉네임을 입력해주세요";
      return;
    }

    final ref = await db
        .collection(FirestoreCollection.member)
        .where("nickname", isEqualTo: nickname.value)
        .get();
    if (ref.size != 0) {
      nicknameErrorMsg.value = "이미 존재하는 닉네임 입니다.";
      isValidNickname.value = false;
      return;
    }

    isValidNickname.value = true;
  }

  Future<bool> checkValidField() async {
    switch (currentWidgetIdx.value) {
      case 0:
        await _checkValidEmail();
        return isValidEmail.value;
      case 1:
        return _checkValidPassword();
      case 2:
        await _checkValidNickname();
        return isValidNickname.value;
      default:
        throw RangeError.index(currentWidgetIdx.value, 3);
    }
  }

  Future<void> createAccount() async {
    isLoading.value = true;
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.value, password: password1.value);
    final member = Member(
        email: email.value,
        nickname: nickname.value,
        profileImg: "",
        statusMessage: "",
        friendUidList: []);

    await db
        .collection(FirestoreCollection.member)
        .doc(userCredential.user?.uid)
        .set(member.toFirestore(), SetOptions(merge: true));
  }
}
