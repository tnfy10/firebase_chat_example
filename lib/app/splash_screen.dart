import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/home/bindings/home_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const/prefs_key.dart';
import 'home/screens/home_screen.dart';
import 'login/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SharedPreferences.getInstance().then((prefs) {
      final uid = prefs.getString(uidKey);
      if (FirebaseAuth.instance.currentUser?.uid == uid) {
        Get.offAll(() => const HomeScreen(), binding: HomeBinding());
      } else {
        Get.offAll(() => LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        color: const Color(0xFFE28Eff),
        child: Image.asset('assets/images/ic_icon.png'),
      ),
    );
  }
}