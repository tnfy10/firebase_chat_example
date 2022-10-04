import 'package:firebase_chat_example/app/home/controllers/chat_controller.dart';
import 'package:firebase_chat_example/app/home/controllers/user_controller.dart';
import 'package:firebase_chat_example/app/home/screens/chat_room_screen.dart';
import 'package:firebase_chat_example/components/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendListScreen extends StatelessWidget with CommonDialog {
  const FriendListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final chatController = Get.find<ChatController>();

    return Scaffold(
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
                      bool result =
                          await userController.addFriend(emailController.text);
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
                            content: userController.errMsg,
                            onPressed: () => Get.back());
                      }
                    },
                    buttonText: "추가");
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Obx(() => userController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    onTap: () {
                      // TODO: 해당 유저 클릭하면 해당 유저와의 1대1 채팅방 생성 후 입장 또는 기존 채팅방 입장
                      Get.to(
                          () => ChatRoomScreen(chatController: chatController));
                    },
                    child: ListTile(
                      leading: Image.network(
                          userController.friendList[index].profileImg ?? "",
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover),
                      title:
                          Text(userController.friendList[index].nickname ?? ""),
                      subtitle: Text(
                          userController.friendList[index].statusMessage ?? ""),
                    ),
                  ),
                );
              },
              itemCount: userController.friendList.length,
            )),
    );
  }
}
