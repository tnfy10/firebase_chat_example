import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sign_up_controller.dart';

class InputEmailScreen extends StatelessWidget {
  InputEmailScreen({super.key});

  final signUpController = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
      child: Column(
        children: [
          const Text(
              '이메일을 입력하세요.',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15
            ),
          ),
          const SizedBox(height: 30),
          TextField(
              onChanged: ((value) {
                signUpController.email.value = value;
              }),
              decoration: InputDecoration(
                  labelText: '이메일',
                  border: const OutlineInputBorder(),
                  errorText: signUpController.isValidEmail.value
                      ? null
                      : signUpController.emailErrorMsg),
              keyboardType: TextInputType.emailAddress)
        ],
      ),
    );
  }
}
