import 'package:firebase_chat_example/app/sign_up/controllers/sign_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputPasswordWidget extends StatelessWidget {
  InputPasswordWidget({super.key});

  final signUpController = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
      child: Column(
        children: [
          const Text(
            '비밀번호를 설정하세요.',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15
            ),
          ),
          const SizedBox(height: 30),
          TextField(
              onChanged: ((value) {
                signUpController.password1.value = value;
              }),
              decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: const OutlineInputBorder(),
                  errorText: signUpController.isValidPassword1.value
                      ? null
                      : signUpController.password1ErrorMsg
              ),
              obscureText: true,
              keyboardType: TextInputType.text),
          const SizedBox(height: 20),
          TextField(
              onChanged: ((value) {
                signUpController.password2.value = value;
              }),
              decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: const OutlineInputBorder(),
                  errorText: signUpController.isValidPassword2.value
                      ? null
                      : signUpController.password2ErrorMsg
              ),
              obscureText: true,
              keyboardType: TextInputType.text),
        ],
      ),
    );
  }

}