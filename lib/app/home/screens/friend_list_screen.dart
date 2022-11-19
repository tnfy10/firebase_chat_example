import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_chat_example/app/home/controllers/chat_controller.dart';
import 'package:firebase_chat_example/app/home/controllers/chat_room_controller.dart';
import 'package:firebase_chat_example/app/home/controllers/user_controller.dart';
import 'package:firebase_chat_example/app/home/screens/chat_room_screen.dart';
import 'package:firebase_chat_example/components/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendListScreen extends StatelessWidget with CommonDialog {
  final chatRoomController = Get.find<ChatRoomController>();

  FriendListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<UserController>(
        builder: (controller) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              title: const Text('친구목록'),
              surfaceTintColor: Theme.of(context).colorScheme.background,
              actions: [
                IconButton(
                    onPressed: () {
                      final emailController = TextEditingController();
                      showTextFormFieldDialog(
                          context: context,
                          title: "친구 추가",
                          controller: emailController,
                          labelText: "이메일",
                          onPressed: () async {
                            bool result = await controller.addFriend(emailController.text);
                            if (result) {
                              Get.back();
                              showOneButtonDialog(
                                  context: context,
                                  title: "추가 완료",
                                  content: "친구 추가가 완료되었습니다.",
                                  onPressed: () => Get.back());
                            } else {
                              showOneButtonDialog(
                                  context: context,
                                  title: "안내",
                                  content: controller.errMsg,
                                  onPressed: () => Get.back());
                            }
                          },
                          buttonText: "추가");
                    },
                    icon: const Icon(Icons.add))
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: controller.friendMap.keys
                  .map((uid) => Card(
                        child: InkWell(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            chatRoomController
                                .startOneOnOneChat(uid)
                                .then((_) {
                              Get.to(() => ChatRoomScreen(), binding: BindingsBuilder(() {
                                Get.put(ChatController(
                                    roomCode: chatRoomController.currentRoomCode,
                                    memberMap: chatRoomController.memberMap));
                              }));
                            });
                          },
                          child: ListTile(
                            leading: CachedNetworkImage(
                                imageUrl: controller.friendMap[uid].profileImg ?? "",
                                imageBuilder: (context, imageProvider) => Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image:
                                          DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    )),
                                placeholder: (_, __) => const SizedBox(
                                    width: 56, height: 56, child: CircularProgressIndicator()),
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.account_circle, size: 56)),
                            title: Text(controller.friendMap[uid].nickname!),
                            subtitle: Text(controller.friendMap[uid].statusMessage!),
                          ),
                        ),
                      ))
                  .toList(),
            )));
  }
}
