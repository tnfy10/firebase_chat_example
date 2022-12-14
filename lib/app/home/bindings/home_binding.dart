import 'package:firebase_chat_example/app/home/controllers/notification_controller.dart';
import 'package:firebase_chat_example/app/home/controllers/user_controller.dart';
import 'package:get/get.dart';

import '../controllers/chat_room_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserController());
    Get.put(ChatRoomController());
    Get.put(NotificationController());
  }
}
