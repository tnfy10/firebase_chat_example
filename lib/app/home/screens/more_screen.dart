import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_chat_example/app/home/controllers/notification_controller.dart';
import 'package:firebase_chat_example/app/home/screens/password_change_screen.dart';
import 'package:firebase_chat_example/components/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_controller.dart';

class MoreScreen extends StatelessWidget with CommonDialog {
  final notificationController = Get.find<NotificationController>();
  final userController = Get.find<UserController>();

  MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('설정'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Obx(() => Column(
                children: [
                  ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: userController.member.value.profileImg ?? '',
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
                    title: Text(userController.member.value.nickname ?? ''),
                    subtitle: Text(userController.member.value.statusMessage ?? ''),
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
                          userController.updateProfileImage();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('닉네임 변경', style: TextStyle(fontSize: 18)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          final nicknameController = TextEditingController();
                          final key = GlobalKey<FormState>();
                          showTextFormFieldDialog(
                              key: key,
                              context: context,
                              title: "닉네임 변경",
                              controller: nicknameController,
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return '변경할 닉네임을 입력해주세요.';
                                } else {
                                  return null;
                                }
                              },
                              labelText: "닉네임",
                              onPressed: () {
                                if (key.currentState?.validate() ?? false) {
                                  userController.updateNickname(nicknameController.text);
                                  Get.back();
                                }
                              },
                              buttonText: "변경");
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('상태 메시지 변경', style: TextStyle(fontSize: 18)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          final statusMsgController = TextEditingController();
                          showTextFormFieldDialog(
                              context: context,
                              title: "상태 메시지 변경",
                              controller: statusMsgController,
                              labelText: "상태 메시지",
                              onPressed: () {
                                userController.updateStatusMessage(statusMsgController.text);
                                Get.back();
                              },
                              buttonText: "변경");
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('메시지 알림', style: TextStyle(fontSize: 18)),
                        trailing: Switch(
                          value: notificationController.isAllowNotification.value,
                          onChanged: (value) {
                            notificationController.allowNotificationToggle(value);
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          activeTrackColor: Theme.of(context).colorScheme.primaryContainer,
                          inactiveThumbColor: Theme.of(context).colorScheme.onPrimary,
                          inactiveTrackColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('비밀번호 설정', style: TextStyle(fontSize: 18)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.to(() => PasswordChangeScreen());
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('회원탈퇴', style: TextStyle(fontSize: 18)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          showTwoButtonDialog(
                              context: context,
                              title: '회원탈퇴',
                              content: '정말로 탈퇴하시겠습니까?\n탈퇴하시면 모든 정보가 삭제됩니다.',
                              positiveBtnText: '탈퇴',
                              onTapNegativeBtn: () {
                                Get.back();
                              },
                              onTapPositiveBtn: () {
                                userController.withdrawal();
                              });
                        },
                      ),
                      const Divider(height: 1),
                    ],
                  )
                ],
              )),
        ));
  }
}
