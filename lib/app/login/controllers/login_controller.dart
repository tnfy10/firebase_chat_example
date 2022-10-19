import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../const/prefs_key.dart';

class LoginController extends GetxController {
  String email = "";
  RxString password = "".obs;

  RxBool isPasswordVisible = false.obs;
  RxBool isLoading = false.obs;

  final firebaseAuth = FirebaseAuth.instance;

  void changePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> fetchLogin() async {
    isLoading.value = true;

    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password.value);
      final prefs = await SharedPreferences.getInstance();
      final uid = userCredential.user?.uid;
      if (uid != null) {
        prefs.setString(uidKey, uid);
      }
    } on FirebaseAuthException catch (e) {
      return Future.error(e);
    } finally {
      isLoading.value = false;
    }
  }
}
