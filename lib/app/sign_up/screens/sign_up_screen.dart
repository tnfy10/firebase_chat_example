import 'package:firebase_chat_example/app/login/bindings/login_binding.dart';
import 'package:firebase_chat_example/app/login/screens/login_screen.dart';
import 'package:firebase_chat_example/app/sign_up/controllers/sign_up_controller.dart';
import 'package:firebase_chat_example/components/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'input_email_widget.dart';
import 'input_nickname_widget.dart';
import 'input_password_widget.dart';

class SignUpScreen extends StatelessWidget with CommonDialog {
  SignUpScreen({super.key});

  final signUpController = Get.find<SignUpController>();

  List<Widget> screens() => [
        InputEmailScreen(signUpController: signUpController),
        InputPasswordWidget(signUpController: signUpController),
        InputNicknameWidget(signUpController: signUpController)
      ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (signUpController.isLoading.value) {
          return false;
        }

        if (signUpController.currentWidgetIdx.value == 0) {
          Get.back();
        } else {
          signUpController.currentWidgetIdx.value--;
        }
        return true;
      },
      child: Obx(
        () => IgnorePointer(
          ignoring: signUpController.isLoading.value,
          child: Scaffold(
              appBar: AppBar(
                title: const Text('회원가입'),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () {
                    if (signUpController.isLoading.value) {
                      return;
                    }

                    if (signUpController.currentWidgetIdx.value == 0) {
                      Get.back();
                    } else {
                      signUpController.currentWidgetIdx.value--;
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              body: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: screens()[
                              signUpController.currentWidgetIdx.value]),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16, bottom: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (await signUpController.checkValidField()) {
                              if (signUpController.currentWidgetIdx.value ==
                                  screens().length - 1) {
                                signUpController.createAccount().then((_) {
                                  showOneButtonDialog(
                                      context: context,
                                      title: "회원가입 완료",
                                      content: "회원가입이 완료되었습니다.",
                                      onPressed: () {
                                        signUpController.isLoading.value =
                                            false;
                                        Get.offAll(LoginScreen(),
                                            binding: LoginBinding());
                                      },
                                      barrierDismissible: false,
                                      allowBackButton: false);
                                }).catchError((e) {
                                  signUpController.isLoading.value = false;
                                  debugPrint(e.toString());
                                  showOneButtonDialog(
                                      context: context,
                                      title: "회원가입 오류",
                                      content:
                                          "회원가입 진행 중 문제가 발생하였습니다.\n잠시 후 다시 시도해주세요.",
                                      onPressed: () {
                                        Get.back();
                                      });
                                });
                              } else {
                                signUpController.currentWidgetIdx.value++;
                              }
                            }
                          },
                          child: const Text('다음'),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                      child: signUpController.isLoading.value
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator())
                          : const SizedBox())
                ],
              )),
        ),
      ),
    );
  }
}
