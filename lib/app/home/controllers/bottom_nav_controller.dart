import 'package:firebase_chat_example/app/home/screens/chat_room_list_screen.dart';
import 'package:firebase_chat_example/app/home/screens/friend_list_screen.dart';
import 'package:firebase_chat_example/app/home/screens/more_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  final List<Widget> screens = [
    const FriendListScreen(),
    const ChatRoomListScreen(),
    const MoreScreen()
  ];

  int currentScreenIdx = 0;
}