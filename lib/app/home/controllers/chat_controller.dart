import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../model/chat_room.dart';

class ChatController extends GetxController {
  RxList<ChatRoom> chatRoomList = <ChatRoom>[].obs;
  RxBool isLoading = false.obs;

  Future<void> getChatRoomList(String uid) async {
    
  }
}