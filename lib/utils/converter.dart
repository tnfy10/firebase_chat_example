import '../app/home/model/chat.dart';

String convertChatText(Chat chat) {
  switch (chat.kind) {
    case SendKind.image:
      return '사진: ${chat.fileName}';
    case SendKind.file:
      return '파일: ${chat.fileName}';
    default:
      return chat.text ?? '';
  }
}