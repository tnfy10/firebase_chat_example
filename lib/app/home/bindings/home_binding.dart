import 'package:firebase_chat_example/app/home/controllers/user_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserController());
  }

}