import 'package:firebase_chat_example/app/home/controllers/chat_room_controller.dart';
import 'package:firebase_chat_example/components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final chatRoomController = Get.find<ChatRoomController>();
  final chatController = Get.find<ChatController>();
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatController.fetchChatHistory(chatRoomController.chatRoomId!);
    //chatController.receiveChatMessage(chatRoomController.chatRoomId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방'),
      ),
      body: Obx(
        () => SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                  child: chatController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: chatController.chatList.length,
                          itemBuilder: (context, index) {
                            final senderUid =
                                chatController.chatList[index].senderUid;
                            final myUid = chatController.auth.currentUser?.uid;
                            final senderProfileImg = chatRoomController
                                .memberProfileImgMap[senderUid];
                            return Row(
                              mainAxisAlignment: myUid == senderUid
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                myUid == senderUid
                                    ? const SizedBox()
                                    : senderProfileImg?.isNotEmpty ?? false
                                        ? Image.network(senderProfileImg!,
                                            width: 30, height: 30)
                                        : const Icon(Icons.account_circle,
                                            size: 30),
                                ChatBubble(
                                    text: chatController.chatList[index].text ??
                                        "") // TODO: 파일도 가능하게 변경
                              ],
                            );
                          })),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      child: TextField(
                    controller: messageController,
                    onSubmitted: (value) {
                      chatController
                          .sendMessage(chatRoomController.chatRoomId!, value)
                          .then((_) {
                        messageController.text = "";
                      });
                    },
                  )),
                  InkWell(
                    onTap: () {
                      chatController
                          .sendMessage(chatRoomController.chatRoomId!,
                              messageController.text)
                          .then((_) {
                        messageController.text = "";
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.send,
                        size: 24,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
