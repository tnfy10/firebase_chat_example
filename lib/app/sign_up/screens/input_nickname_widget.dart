import 'package:firebase_chat_example/app/sign_up/controllers/sign_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputNicknameWidget extends StatelessWidget {
  InputNicknameWidget({super.key});

  final signUpController = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
      child: Column(
        children: [
          const Text(
            '닉네임을 설정하세요.',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15
            ),
          ),
          const SizedBox(height: 30),
          TextField(
              onChanged: ((value) {
                signUpController.nickname.value = value;
              }),
              decoration: InputDecoration(
                  labelText: '닉네임',
                  border: const OutlineInputBorder(),
                  errorText: signUpController.isValidNickname.value
                      ? null
                      : "이미 존재하는 닉네임입니다."),
              keyboardType: TextInputType.text)
        ],
      ),
    );
  }

}