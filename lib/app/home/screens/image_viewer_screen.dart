import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_chat_example/utils/download_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ImageViewerScreen extends StatelessWidget {
  final String fileName;
  final String imgUrl;
  final String senderName;
  final int sendDateMsEpoch;

  const ImageViewerScreen(
      {super.key,
      required this.fileName,
      required this.imgUrl,
      required this.senderName,
      required this.sendDateMsEpoch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF222222),
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
            Text(senderName, style: const TextStyle(color: Colors.white, fontSize: 14)),
            Text(
                DateFormat('yyyy-MM-dd aa hh:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(sendDateMsEpoch)),
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
      body: Column(
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
                            image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
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
          GestureDetector(
            onTap: () {
              Get.snackbar('다운로드 시작', fileName,
                  colorText: Colors.black, backgroundColor: const Color(0xB3D5D5D5));
              DownloadUtil.downloadFile(imgUrl, fileName).then((_) {
                Get.snackbar('다운로드 완료', fileName,
                    colorText: Colors.black, backgroundColor: const Color(0xB3D5D5D5));
              });
            },
            child: Container(
              color: const Color(0xFF222222),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: const Text('다운로드', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}
