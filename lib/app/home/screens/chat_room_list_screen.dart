import 'package:flutter/material.dart';

class ChatRoomListScreen extends StatelessWidget {
  const ChatRoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Text('채팅')
        ],
      ),
    );
  }

}