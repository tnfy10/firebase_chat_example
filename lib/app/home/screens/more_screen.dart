import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';

import '../controllers/user_controller.dart';

class MoreScreen extends StatelessWidget {
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
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                  child: Divider(
                    height: 1,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
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
                          controller.updateNickname();
                        },
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
                  ),
                )
              ],
            );
          }),
        ));
  }
}
