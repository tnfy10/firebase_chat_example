import 'package:firebase_chat_example/app/home/controllers/user_controller.dart';
import 'package:firebase_chat_example/components/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordChangeScreen extends StatelessWidget with CommonDialog {
  final userController = Get.find<UserController>();
  final oldPwdController = TextEditingController();
  final newPwd1Controller = TextEditingController();
  final newPwd2Controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  PasswordChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          return !userController.isLoading.value;
        },
        child: IgnorePointer(
          ignoring: userController.isLoading.value,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              title: const Text('비밀번호 변경'),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                              controller: oldPwdController,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return '비밀번호를 입력해주세요.';
                                } else if (value.length < 6) {
                                  return '올바른 비밀번호를 입력해주세요.';
                                } else {
                                  return null;
                                }
                              },
                              decoration: const InputDecoration(
                                  labelText: '기존 비밀번호', border: OutlineInputBorder()),
                              obscureText: true,
                              keyboardType: TextInputType.text),
                          const SizedBox(height: 30),
                          TextFormField(
                              controller: newPwd1Controller,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return '새 비밀번호를 입력해주세요.';
                                } else if (value.length < 6) {
                                  return '올바른 새 비밀번호를 입력해주세요.';
                                } else {
                                  return null;
                                }
                              },
                              decoration: const InputDecoration(
                                  labelText: '새 비밀번호', border: OutlineInputBorder()),
                              obscureText: true,
                              keyboardType: TextInputType.text),
                          const SizedBox(height: 15),
                          TextFormField(
                              controller: newPwd2Controller,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return '새 비밀번호 확인을 입력해주세요.';
                                } else if (value.length < 6) {
                                  return '올바른 새 비밀번호 확인을 입력해주세요.';
                                } else {
                                  return null;
                                }
                              },
                              decoration: const InputDecoration(
                                  labelText: '새 비밀번호 확인', border: OutlineInputBorder()),
                              obscureText: true,
                              keyboardType: TextInputType.text),
                          const Spacer(),
                          ElevatedButton(
                              onPressed: () {
                                final validate = formKey.currentState?.validate() ?? false;
                                final oldPwd = oldPwdController.text.trim();
                                final newPwd1 = newPwd1Controller.text.trim();
                                final newPwd2 = newPwd2Controller.text.trim();
                                if (!validate) {
                                  return;
                                } else if (newPwd1 != newPwd2) {
                                  showOneButtonDialog(
                                      context: context,
                                      title: '안내',
                                      content: '새 비밀번호가 일치하지 않습니다.',
                                      onPressed: () {
                                        Get.back();
                                      });
                                } else {
                                  userController.updatePassword(oldPwd, newPwd1, onComplete: () {
                                    showOneButtonDialog(
                                        context: context,
                                        title: '안내',
                                        content: '비밀번호 변경이 완료되었습니다.',
                                        onPressed: () {
                                          Get.back();
                                        },
                                        barrierDismissible: false,
                                        allowBackButton: false,
                                        completeCallback: (_) {
                                          Get.back();
                                        });
                                  }, onError: (errMsg) {
                                    showOneButtonDialog(
                                        context: context,
                                        title: '안내',
                                        content: errMsg,
                                        onPressed: () {
                                          Get.back();
                                        });
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(MediaQuery.of(context).size.width, 50)),
                              child: const Text('비밀번호 변경')),
                        ],
                      ),
                    ),
                  ),
                  userController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
