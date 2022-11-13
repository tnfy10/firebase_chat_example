import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/home/bindings/home_binding.dart';
import 'package:firebase_chat_example/app/home/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/login/screens/login_screen.dart';
import 'const/prefs_key.dart';
import 'themes/theme_data.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var prefs = await SharedPreferences.getInstance();
  var uid = prefs.getString(uidKey);
  FlutterNativeSplash.remove();
  runApp(App(uid: uid));
}

class App extends StatelessWidget {
  final String? uid;

  const App({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      home: _getStartScreen(uid),
      initialBinding: HomeBinding(),
    );
  }

  Widget _getStartScreen(String? uid) {
    if (uid?.isEmpty ?? true) {
      return LoginScreen();
    }

    if (FirebaseAuth.instance.currentUser?.uid == uid) {
      return const HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}
