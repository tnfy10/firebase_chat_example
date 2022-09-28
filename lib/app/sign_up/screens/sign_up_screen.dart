import 'package:firebase_chat_example/app/sign_up/controllers/sign_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final signUpController = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (signUpController.currentWidgetIdx.value == 0) {
          Get.back();
        } else {
          signUpController.currentWidgetIdx.value--;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('회원가입'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              if (signUpController.currentWidgetIdx.value == 0) {
                Get.back();
              } else {
                signUpController.currentWidgetIdx.value--;
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: Obx(() => signUpController
                    .screens[signUpController.currentWidgetIdx.value])),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: ElevatedButton(
                onPressed: () {
                  if (signUpController.currentWidgetIdx.value ==
                      signUpController.screens.length - 1) {
                    signUpController.createAccount();
                    Get.back();
                  } else if (signUpController.checkValidField()) {
                    signUpController.currentWidgetIdx.value++;
                  }
                },
                child: const Text('다음'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
