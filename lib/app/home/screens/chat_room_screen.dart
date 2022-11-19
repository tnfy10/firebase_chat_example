import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_chat_example/app/home/model/chat.dart';
import 'package:firebase_chat_example/components/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';

class ChatRoomScreen extends StatelessWidget {
  final messageController = TextEditingController();
  final textFieldFocus = FocusNode();

  ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ChatController>(
        builder: (controller) => WillPopScope(
              onWillPop: () async {
                if (controller.isOpenFileSend.value) {
                  controller.isOpenFileSend.value = false;
                  return false;
                } else {
                  return true;
                }
              },
              child: Scaffold(
                  appBar: AppBar(
                    title: const Text('채팅방'),
                  ),
                  body: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                            child: controller.isLoading.value
                                ? const Center(child: CircularProgressIndicator())
                                : Align(
                                    alignment: Alignment.topCenter,
                                    child: ListView.builder(
                                        reverse: true,
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.only(top: 10),
                                        controller: ScrollController(),
                                        itemCount: controller.chatList.length,
                                        itemBuilder: (context, index) {
                                          final senderUid = controller.chatList[index].senderUid;
                                          final myUid = controller.auth.currentUser?.uid;
                                          final senderProfileImg =
                                              controller.memberMap[senderUid]?.profileImg ?? '';
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
                                                    : Padding(
                                                        padding: const EdgeInsets.only(left: 10),
                                                        child: CachedNetworkImage(
                                                            imageUrl: senderProfileImg,
                                                            imageBuilder: (context, imageProvider) {
                                                              return Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    image: DecorationImage(
                                                                        image: imageProvider,
                                                                        fit: BoxFit.cover),
                                                                  ));
                                                            },
                                                            progressIndicatorBuilder:
                                                                (context, _, __) {
                                                              return const SizedBox(
                                                                  width: 50,
                                                                  height: 50,
                                                                  child:
                                                                      CircularProgressIndicator());
                                                            },
                                                            errorWidget: (_, __, ___) {
                                                              return const Icon(
                                                                  Icons.account_circle,
                                                                  size: 50);
                                                            }),
                                                      ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 10),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      myUid == senderUid
                                                          ? const SizedBox()
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets.only(bottom: 5),
                                                              child: Text(controller
                                                                      .memberMap[senderUid]
                                                                      ?.nickname ??
                                                                  ''),
                                                            ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          switch (controller.chatList[index].kind) {
                                                            case SendKind.image:
                                                            case SendKind.file:
                                                              controller.downloadFile(
                                                                  controller.chatList[index].text,
                                                                  controller
                                                                      .chatList[index].fileName);
                                                              break;
                                                            default:
                                                              break;
                                                          }
                                                        },
                                                        child: ChatBubble(
                                                            chat: controller.chatList[index],
                                                            isMe: myUid == senderUid),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                if (controller.isOpenFileSend.value) {
                                  controller.isOpenFileSend.value = false;
                                } else {
                                  controller.isOpenFileSend.value = true;
                                  textFieldFocus.unfocus();
                                }
                              },
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
                                child: Focus(
                              onFocusChange: (hasFocus) {
                                if (hasFocus) {
                                  controller.isOpenFileSend.value = false;
                                }
                              },
                              child: TextField(
                                focusNode: textFieldFocus,
                                controller: messageController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                    border: InputBorder.none),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    controller.sendMessage(value).then((_) {
                                      messageController.text = "";
                                    });
                                  }
                                  textFieldFocus.requestFocus();
                                },
                              ),
                            )),
                            InkWell(
                              onTap: () {
                                if (messageController.text.trim().isNotEmpty) {
                                  controller.sendMessage(messageController.text).then((_) {
                                    messageController.text = "";
                                  });
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
                        ),
                        controller.isOpenFileSend.value
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                alignment: Alignment.center,
                                color: const Color(0xFFEDEDED),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          controller.sendImage();
                                        },
                                        icon: SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.image,
                                                size: 30,
                                              ),
                                              SizedBox(height: 10),
                                              Text('사진')
                                            ],
                                          ),
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          controller.sendFile();
                                        },
                                        icon: SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.file_present,
                                                size: 30,
                                              ),
                                              SizedBox(height: 10),
                                              Text('파일')
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  )),
            ));
  }
}
