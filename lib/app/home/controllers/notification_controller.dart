import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_example/app/home/model/member.dart';
import 'package:firebase_chat_example/const/prefs_key.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../const/firestore_collection.dart';
import '../../../const/notification_id.dart';
import '../model/chat.dart';
import 'chat_controller.dart';

class NotificationController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  RxBool isAllowNotification = true.obs;

  @override
  void onInit() {
    super.onInit();
    initAllowedNotification();
    receiveMessage();
  }

  void initAllowedNotification() async {
    final prefs = await SharedPreferences.getInstance();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission()
        .then((value) {
      prefs.setBool(notificationKey, value ?? false);
      isAllowNotification.value = value ?? false;
    });
  }

  Future<void> allowNotificationToggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    isAllowNotification.value = value;
    if (value) {
      prefs.setBool(notificationKey, value);
    } else {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission()
          .then((value) {
        prefs.setBool(notificationKey, value ?? false);
      });
    }
  }

  void receiveMessage() async {
    if (auth.currentUser?.uid != null) {
      final roomRefList = await db
          .collection(FirestoreCollection.chatRoom)
          .where('uidList', arrayContains: auth.currentUser?.uid)
          .get();

      final roomCodeList = roomRefList.docs.map((e) => e.id).toList();

      db
          .collection(FirestoreCollection.chat)
          .where('roomCode', whereIn: roomCodeList)
          .snapshots()
          .listen((event) {
        if (isAllowNotification.value) {
          for (var item in event.docChanges) {
            if (item.type == DocumentChangeType.added) {
              final chat = Chat.fromFirestore(item.doc);
              if (chat.senderUid != auth.currentUser?.uid && currentRoomCode != chat.roomCode) {
                pushNotification(chat);
              }
            }
          }
        }
      });
    }
  }

  void pushNotification(Chat chat) {
    db.collection(FirestoreCollection.member).doc(chat.senderUid).get().then((value) {
      final member = Member.fromFirestore(value);
      flutterLocalNotificationsPlugin.show(
        notificationId,
        member.nickname,
        chat.text,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            '메시지 알림',
            icon: 'ic_icon',
            importance: Importance.high,
          ),
        ),
      );
    });
  }
}
