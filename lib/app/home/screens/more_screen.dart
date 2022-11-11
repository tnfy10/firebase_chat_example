import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_chat_example/components/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';

import '../controllers/user_controller.dart';

class MoreScreen extends StatelessWidget with CommonDialog {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('설정'),
        ),
        body: SafeArea(
          child: GetX<UserController>(builder: (controller) {
            return Column(
              children: [
                ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: controller.member.value.profileImg ?? '',
                    imageBuilder: (context, imageProvider) {
                      return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          ));
                    },
                    progressIndicatorBuilder: (_, __, ___) {
                      return const SizedBox(
                          width: 56, height: 56, child: CircularProgressIndicator());
                    },
                    errorWidget: (_, __, ___) {
                      return const Icon(Icons.account_circle, size: 56);
                    },
                  ),
                  title: Text(controller.member.value.nickname ?? ''),
                  subtitle: Text(controller.member.value.statusMessage ?? ''),
                ),
                ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 20),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('프로필 이미지 변경', style: TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        controller.updateProfileImage();
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('닉네임 변경', style: TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        final nicknameController = TextEditingController();
                        showTextFormFieldDialog(
                            context: context,
                            title: "닉네임 변경",
                            controller: nicknameController,
                            labelText: "닉네임",
                            onPressed: () {
                              controller.updateNickname(
                                  nickname: nicknameController.text,
                                  resultCallback: (result, message) {
                                    if (result) {
                                      Get.back();
                                    } else {
                                      showOneButtonDialog(
                                          context: context,
                                          title: "안내",
                                          content: message,
                                          onPressed: () => Get.back());
                                    }
                                  });
                            },
                            buttonText: "변경");
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('상태 메시지 변경', style: TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('알림 설정', style: TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('비밀번호 설정', style: TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('회원탈퇴', style: TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                  ],
                )
              ],
            );
          }),
        ));
  }
}
