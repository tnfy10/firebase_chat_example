import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String sendTime;
  final bool isMe;

  const ChatBubble({super.key, required this.text, required this.sendTime, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isMe
            ? Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(sendTime,
                    style: TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              )
            : const SizedBox(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          constraints: const BoxConstraints(maxWidth: 170),
          decoration: BoxDecoration(
              color: isMe ? Theme.of(context).colorScheme.primaryContainer : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(3)),
              boxShadow: const [BoxShadow()]),
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        isMe
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(sendTime,
                    style: TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
              ),
      ],
    );
  }
}
