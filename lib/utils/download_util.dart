import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class DownloadUtil {
  static Future<void> downloadFile(String? url, String? fileName) async {
    if (url == null || fileName == null) {
      return;
    }

    final httpsReference = FirebaseStorage.instance.refFromURL(url);
    final filePath = await getDownloadPath();
    final file = File('$filePath/$fileName');
    final downloadTask = httpsReference.writeToFile(file);

    downloadTask.snapshotEvents.listen((taskSnapshot) {
      debugPrint(taskSnapshot.totalBytes.toString());
      switch (taskSnapshot.state) {
        case TaskState.running:
          debugPrint('다운로드 중');
          break;
        case TaskState.paused:
          debugPrint('일시정지');
          break;
        case TaskState.success:
          debugPrint('다운로드 완료');
          break;
        case TaskState.canceled:
          debugPrint('다운로드 취소');
          break;
        case TaskState.error:
          debugPrint('다운로드 에러');
          break;
      }
    });
  }

  static Future<String> getDownloadPath() async {
    final completer = Completer<String>();
    try {
      if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        completer.complete(dir.path);
      } else {
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          completer.complete(directory.path);
        } else {
          completer.completeError('ChatController::getDownloadPath::error:다운로드 폴더가 존재하지 않음.');
        }
      }
    } catch (e) {
      completer.completeError('ChatController::getDownloadPath::error:${e.toString()}');
    }
    return completer.future;
  }
}