import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;

  const ChatBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        boxShadow: const [
          BoxShadow()
        ]
      ),
      child: Text(
          text,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface
        ),
      ),
    );
  }
}
