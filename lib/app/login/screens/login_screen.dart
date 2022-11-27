import 'package:firebase_chat_example/app/login/screens/find_password_screen.dart';
import 'package:firebase_chat_example/app/home/bindings/home_binding.dart';
import 'package:firebase_chat_example/app/sign_up/bindings/sign_up_binding.dart';
import 'package:firebase_chat_example/app/sign_up/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/common_dialog.dart';
import '../../home/screens/home_screen.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget with CommonDialog {
  LoginScreen({Key? key}) : super(key: key);

  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          IgnorePointer(
            ignoring: loginController.isLoading.value,
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Theme.of(context).colorScheme.background,
                body: SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          Image.asset(
                            "assets/images/ic_icon_none_background.png",
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 50),
                          TextField(
                            onChanged: ((value) {
                              loginController.email = value;
                            }),
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            onChanged: ((value) {
                              loginController.password.value = value;
                            }),
                            decoration: InputDecoration(
                                labelText: '비밀번호',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                    iconSize: 20,
                                    highlightColor: Colors.transparent,
                                    onPressed: () {
                                      loginController.changePasswordVisibility();
                                    },
                                    icon: Icon(loginController.password.value.isNotEmpty
                                        ? loginController.isPasswordVisible.value
                                            ? Icons.visibility_off
                                            : Icons.visibility
                                        : null))),
                            obscureText: !loginController.isPasswordVisible.value,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _loginButton(context),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                              onPressed: () => _loginButton(context),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(MediaQuery.of(context).size.width, 50)),
                              child: const Text('로그인')),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Get.to(() => SignUpScreen(), binding: SignUpBinding());
                            },
                            child: const Text(
                              "회원가입",
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                          )
                        ],
                      )),
                      TextButton(
                        onPressed: () {
                          Get.to(() => FindPasswordScreen());
                        },
                        child: const Text("비밀번호를 잊으셨나요?"),
                      )
                    ],
                  ),
                ))),
          ),
          loginController.isLoading.value
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.black12),
                  child: const CircularProgressIndicator(),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  void _loginButton(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    loginController.fetchLogin().then((_) {
      Get.off(() => const HomeScreen(), binding: HomeBinding());
      Get.delete<LoginController>();
    }).catchError((e) {
      showOneButtonDialog(
          context: context,
          title: "로그인 오류",
          content: "이메일 또는 비밀번호를 확인해주세요.",
          onPressed: () {
            Get.back();
          });
    });
  }
}
