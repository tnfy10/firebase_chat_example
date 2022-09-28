import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../screens/input_email_widget.dart';
import '../screens/input_nickname_widget.dart';
import '../screens/input_password_widget.dart';

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

  String? emailErrorMsg;
  String? password1ErrorMsg;
  String? password2ErrorMsg;
  String? nicknameErrorMsg;

  final List<Widget> screens = [
    InputEmailScreen(),
    InputPasswordWidget(),
    InputNicknameWidget()
  ];

  var firebaseAuth = FirebaseAuth.instance;

  void _checkValidEmail() {
    if (email.value.isEmpty) {
      emailErrorMsg = "이메일을 입력해주세요";
      isValidEmail.value = false;
      return;
    }

    var regExp = RegExp(
        r"^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$");
    if (regExp.hasMatch(email.value)) {
      emailErrorMsg = "이메일이 올바르지 않습니다.";
      isValidEmail.value = false;
      return;
    }

    emailErrorMsg = null;
    isValidEmail.value = true;
  }

  bool _checkValidPassword() {
    if (password1.value
        .trim()
        .isEmpty) {
      password1ErrorMsg = "비밀번호를 입력해주세요.";
      isValidPassword1.value = false;
    } else {
      password1ErrorMsg = null;
      isValidPassword1.value = true;
    }

    if (password2.value
        .trim()
        .isEmpty) {
      password2ErrorMsg = "비밀번호 확인을 입력해주세요.";
      isValidPassword2.value = false;
    } else {
      password2ErrorMsg = null;
      isValidPassword2.value = true;
    }

    if (password1.value.trim() == password2.value.trim()) {
      password1ErrorMsg = null;
      password2ErrorMsg = null;
      isValidPassword1.value = true;
      isValidPassword2.value = true;
      return true;
    }

    return false;
  }

  void _checkValidNickname() {
    if (nickname.value.isEmpty) {
      isValidNickname.value = false;
      nicknameErrorMsg = "닉네임을 입력해주세요";
    }

    isValidNickname.value = true;
    nicknameErrorMsg = null;
  }

  bool checkValidField() {
    switch (currentWidgetIdx.value) {
      case 0:
        _checkValidEmail();
        return isValidEmail.value;
      case 1:
        return _checkValidPassword();
      case 2:
        _checkValidNickname();
        return isValidNickname.value;
      default:
        throw RangeError.index(currentWidgetIdx.value, screens);
    }
  }

  void createAccount() async {
    isLoading.value = true;
    var userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.value, password: password1.value);
    await userCredential.user?.updateDisplayName(nickname.value);
    isLoading.value = false;
  }
}
