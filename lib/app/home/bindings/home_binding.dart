import 'package:firebase_chat_example/app/home/controllers/bottom_nav_controller.dart';
import 'package:firebase_chat_example/app/home/controllers/user_controller.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavController());
    Get.put(UserController());
    Get.lazyPut(() => ChatController());
  }

}