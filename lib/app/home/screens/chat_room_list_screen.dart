import 'package:firebase_chat_example/app/home/controllers/chat_room_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';
import 'chat_room_screen.dart';

class ChatRoomListScreen extends StatelessWidget {
  const ChatRoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ChatRoomController>(
        builder: (controller) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              title: const Text('채팅'),
              surfaceTintColor: Theme.of(context).colorScheme.background,
            ),
            body: SafeArea(
                child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: controller.chatRoomMap.keys
                  .map((roomCode) => Card(
                        child: InkWell(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            controller
                                .fetchMemberList(controller.chatRoomMap[roomCode].uidList!)
                                .then((_) {
                              Get.to(() => ChatRoomScreen(), binding: BindingsBuilder(() {
                                Get.put(ChatController(
                                    roomCode: roomCode,
                                    memberMap: controller.memberMap));
                              }));
                            });
                          },
                          child: ListTile(
                            title: Text(controller.chatRoomMap[roomCode].roomName!),
                            subtitle: Text(controller.chatRoomMap[roomCode].recentMsg!),
                          ),
                        ),
                      ))
                  .toList(),
            ))));
  }
}
