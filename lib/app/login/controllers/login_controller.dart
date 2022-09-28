import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  String email = "";
  RxString password = "".obs;

  RxBool isPasswordVisible = false.obs;
  RxBool isLoading = false.obs;

  var firebaseAuth = FirebaseAuth.instance;

  void changePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> fetchLogin() async {
    isLoading.value = true;

    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password.value);
    } on FirebaseAuthException catch (e) {
      return Future.error(e);
    } finally {
      isLoading.value = false;
    }
  }
}
