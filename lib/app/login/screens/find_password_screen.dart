import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/login/bindings/login_binding.dart';
import 'package:firebase_chat_example/app/login/screens/login_screen.dart';
import 'package:firebase_chat_example/components/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindPasswordScreen extends StatelessWidget with CommonDialog {
  FindPasswordScreen({super.key});

  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 재설정'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: Column(
          children: [
            const Text(
              '가입하신 이메일로\n비밀번호 재설정 주소를 전송합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 50),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  var email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);
                      showOneButtonDialog(
                          context: context,
                          title: "전송 완료",
                          content: "작성한 이메일로 비밀번호 재설정 주소가 전송되었습니다.",
                          onPressed: () {
                            Get.offAll(() => LoginScreen(),
                                binding: LoginBinding());
                          },
                          allowBackButton: false,
                          barrierDismissible: false);
                    } catch (e) {
                      debugPrint(e.toString());
                      showOneButtonDialog(
                          context: context,
                          title: "안내",
                          content: "전송 중 문제가 발생하였습니다.\n다시 시도해주세요.",
                          onPressed: () {
                            Get.back();
                          });
                    }
                  } else {
                    showOneButtonDialog(
                        context: context,
                        title: "안내",
                        content: "올바른 이메일을 적어주세요.",
                        onPressed: () {
                          Get.back();
                        });
                  }
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(MediaQuery.of(context).size.width, 50)),
                child: const Text('비밀번호 재설정 주소 받기'))
          ],
        ),
      ),
    );
  }
}
