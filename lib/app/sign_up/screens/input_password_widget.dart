import 'package:firebase_chat_example/app/sign_up/controllers/sign_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class InputPasswordWidget extends StatelessWidget {
  final SignUpController signUpController;

  const InputPasswordWidget({super.key, required this.signUpController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
      child: Column(
        children: [
          const Text(
            '비밀번호를 설정하세요.',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          const SizedBox(height: 30),
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextFormField(
                  initialValue: signUpController.password1.value,
                  onChanged: ((value) {
                    signUpController.password1.value = value;
                  }),
                  decoration: InputDecoration(
                      labelText: '비밀번호',
                      border: const OutlineInputBorder(),
                      errorText: signUpController.isValidPassword1.value
                          ? null
                          : signUpController.password1ErrorMsg.value),
                  obscureText: true,
                  keyboardType: TextInputType.text),
            ),
          ),
          Obx(
            () => TextFormField(
                initialValue: signUpController.password2.value,
                onChanged: ((value) {
                  signUpController.password2.value = value;
                }),
                decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    border: const OutlineInputBorder(),
                    errorText: signUpController.isValidPassword2.value
                        ? null
                        : signUpController.password2ErrorMsg.value),
                obscureText: true,
                keyboardType: TextInputType.text),
          ),
        ],
      ),
    );
  }
}
