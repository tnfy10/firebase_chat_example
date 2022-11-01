import 'package:firebase_chat_example/app/home/controllers/chat_room_controller.dart';
import 'package:firebase_chat_example/app/home/controllers/chat_room_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomListScreen extends StatelessWidget {
  const ChatRoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatRoomListController = Get.find<ChatRoomListController>();
    final chatRoomController = Get.find<ChatRoomController>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('채팅'),
        surfaceTintColor: Theme.of(context).colorScheme.background,
      ),
      body: SafeArea(
        child: Obx(() => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    onTap: () {
                      chatRoomController
                          .enterChatRoom(chatRoomListController.chatRoomList[index]);
                    },
                    child: ListTile(
                      title: Text(chatRoomListController.chatRoomList[index].roomName),
                      subtitle: Text(chatRoomListController.chatRoomList[index].recentMsg),
                    ),
                  ),
                );
              },
              itemCount: chatRoomListController.chatRoomList.length,
            )),
      ),
    );
  }
}
