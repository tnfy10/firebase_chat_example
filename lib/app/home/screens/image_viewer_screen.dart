import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_chat_example/app/home/controllers/chat_controller.dart';
import 'package:firebase_chat_example/themes/color_scheme.dart';
import 'package:firebase_chat_example/utils/download_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ImageViewerScreen extends StatelessWidget {
  final int index;

  const ImageViewerScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetX<ChatController>(
      builder: (controller) {
        final nickname = controller.memberMap[controller.chatList[index].senderUid!]!.nickname!;
        final fileName = controller.chatList[index].fileName!;
        final imgUrl = controller.chatList[index].text!;
        final msEpoch = controller.chatList[index].sendMillisecondEpoch!;

        return IgnorePointer(
          ignoring: controller.isLoading.value,
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xFF222222),
                  centerTitle: false,
                  leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      )),
                  titleSpacing: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nickname, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      Text(
                          DateFormat('yyyy-MM-dd aa hh:mm')
                              .format(DateTime.fromMillisecondsSinceEpoch(msEpoch)),
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                body: SafeArea(
                    child: Column(
                  children: [
                    Expanded(
                        child: Center(
                      child: Hero(
                        tag: fileName,
                        child: InteractiveViewer(
                          child: CachedNetworkImage(
                              imageUrl: imgUrl,
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider, fit: BoxFit.contain),
                                    ));
                              },
                              placeholder: (context, _) {
                                return Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator());
                              }),
                        ),
                      ),
                    )),
                    Row(
                      children: [
                        Flexible(
                            child: GestureDetector(
                          onTap: () {
                            Get.snackbar('다운로드 시작', fileName,
                                colorText: Colors.black, backgroundColor: const Color(0xB3D5D5D5));
                            DownloadUtil.downloadFile(imgUrl, fileName).then((_) {
                              Get.snackbar('다운로드 완료', fileName,
                                  colorText: Colors.black,
                                  backgroundColor: const Color(0xB3D5D5D5));
                            });
                          },
                          child: Container(
                            color: const Color(0xFF222222),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            alignment: Alignment.center,
                            child: const Text('다운로드',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        )),
                        Flexible(
                            child: GestureDetector(
                          onTap: () async {
                            final imageData = await controller.getImageData(imgUrl);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                      backgroundColor: Colors.black54,
                                      shape: const Border(),
                                      child: GridView.count(
                                        padding: const EdgeInsets.only(top: 15, left: 15),
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        childAspectRatio: 5,
                                        children: [
                                          const Text(
                                            '종류',
                                            style: TextStyle(color: Colors.white, fontSize: 17),
                                          ),
                                          Text(
                                            imageData.kind,
                                            style:
                                                const TextStyle(color: Colors.white, fontSize: 17),
                                          ),
                                          const Text(
                                            '크기',
                                            style: TextStyle(color: Colors.white, fontSize: 17),
                                          ),
                                          Text(
                                            imageData.mByteValue,
                                            style:
                                                const TextStyle(color: Colors.white, fontSize: 17),
                                          ),
                                          const Text(
                                            '해상도',
                                            style: TextStyle(color: Colors.white, fontSize: 17),
                                          ),
                                          Text(
                                            imageData.resolution,
                                            style:
                                                const TextStyle(color: Colors.white, fontSize: 17),
                                          )
                                        ],
                                      ));
                                });
                          },
                          child: Container(
                            color: const Color(0xFF222222),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            alignment: Alignment.center,
                            child: const Text('상세 보기',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ))
                      ],
                    )
                  ],
                )),
              ),
              controller.isLoading.value
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(color: lightColorScheme.primaryContainer))
                  : const SizedBox()
            ],
          ),
        );
      },
    );
  }
}
