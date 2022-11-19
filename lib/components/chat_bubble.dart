import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/home/model/chat.dart';

class ChatBubble extends StatelessWidget {
  final dateFormat = DateFormat('HH:mm');
  final Chat chat;
  final bool isMe;

  ChatBubble({super.key, required this.chat, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isMe
            ? Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                    dateFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(chat.sendMillisecondEpoch ?? 0)),
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface)),
              )
            : const SizedBox(),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
                color: isMe ? Theme.of(context).colorScheme.primaryContainer : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                boxShadow: const [BoxShadow()]),
            child: chatContent(context)),
        isMe
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                    dateFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(chat.sendMillisecondEpoch ?? 0)),
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
      ],
    );
  }

  Widget chatContent(BuildContext context) {
    switch (chat.kind) {
      case SendKind.image:
        return CachedNetworkImage(
            placeholder: (context, _) {
              return Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator());
            },
            imageUrl: chat.text ?? '',
            imageBuilder: (context, imageProvider) {
              return Container(
                  margin: const EdgeInsets.all(10),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ));
            },
            errorWidget: (_, __, ___) {
              return Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  child: const Icon(Icons.error, size: 50));
            });
      case SendKind.file:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(
                Icons.file_download,
                size: 24,
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 130,
                child: Column(
                  children: [
                    Text(
                      chat.fileName ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      default:
        return Text(
          chat.text ?? '',
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface),
        );
    }
  }
}
