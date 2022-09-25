import 'package:flutter/material.dart';

mixin CommonDialog {
  void showOneButtonDialog(
      {required BuildContext context,
      required String title,
      required String content,
      String buttonText = "확인",
      required VoidCallback onPressed}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            content: Text(content),
            actions: [
              TextButton(onPressed: onPressed, child: Text(buttonText))
            ],
          );
        });
  }
}
