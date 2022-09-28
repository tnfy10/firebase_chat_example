import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  User? user;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user = FirebaseAuth.instance.currentUser!;
    debugPrint("테스트: ${user?.email}");
  }
}