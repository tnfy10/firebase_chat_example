import 'package:firebase_chat_example/app/home/controllers/chat_room_controller.dart';
import 'package:firebase_chat_example/components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_controller.dart';

class ChatRoomScreen extends StatelessWidget {
  final chatRoomController = Get.find<ChatRoomController>();
  final chatController = Get.find<ChatController>();
  final messageController = TextEditingController();
  final focusNode = FocusNode();

  ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방'),
      ),
      body: Obx(
        () {
          final scrollController = ScrollController();
          SchedulerBinding.instance.addPostFrameCallback((_) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          });
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: chatController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            controller: scrollController,
                            itemCount: chatController.chatList.length,
                            itemBuilder: (context, index) {
                              final senderUid = chatController.chatList[index].senderUid;
                              final myUid = chatController.auth.currentUser?.uid;
                              final senderProfileImg =
                                  chatRoomController.memberProfileImgMap[senderUid];
                              final dateFormat = DateFormat('HH:mm');
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment: myUid == senderUid
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    myUid == senderUid
                                        ? const SizedBox()
                                        : senderProfileImg?.isNotEmpty ?? false
                                            ? Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: Image.network(senderProfileImg!,
                                                    width: 50,
                                                    height: 50, loadingBuilder: (context, _, __) {
                                                  return const SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: CircularProgressIndicator());
                                                }, errorBuilder: (_, __, ___) {
                                                  return const Icon(Icons.account_circle, size: 50);
                                                }),
                                              )
                                            : const Icon(Icons.account_circle, size: 50),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          myUid == senderUid
                                              ? const SizedBox()
                                              : Padding(
                                                  padding: const EdgeInsets.only(bottom: 5),
                                                  child: Text(
                                                      chatRoomController.memberList[0].nickname ??
                                                          ''),
                                                ),
                                          ChatBubble(
                                              text: chatController.chatList[index].text ?? "",
                                              sendTime: dateFormat.format(
                                                  DateTime.fromMillisecondsSinceEpoch(chatController
                                                          .chatList[index].sendMillisecondEpoch ??
                                                      0)),
                                              isMe: myUid == senderUid)
                                        ],
                                      ),
                                    ),
                                    // TODO: 파일도 가능하게 변경
                                  ],
                                ),
                              );
                            })),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Expanded(
                        child: TextField(
                      focusNode: focusNode,
                      controller: messageController,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          border: InputBorder.none),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          chatController.sendMessage(chatRoomController.roomCode!, value).then((_) {
                            messageController.text = "";
                          });
                        }
                      },
                    )),
                    InkWell(
                      onTap: () {
                        if (messageController.text.trim().isNotEmpty) {
                          chatController
                              .sendMessage(chatRoomController.roomCode!, messageController.text)
                              .then((_) {
                            messageController.text = "";
                          });
                          focusNode.requestFocus();
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        color: Theme.of(context).colorScheme.primaryContainer,
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
          );
        },
      ),
    );
  }
}
