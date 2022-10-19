import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin CommonDialog {
  void showOneButtonDialog(
      {required BuildContext context,
      required String title,
      required String content,
      String buttonText = "확인",
      required VoidCallback onPressed,
      bool barrierDismissible = true,
      bool allowBackButton = true}) {
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return allowBackButton;
            },
            child: AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              content: Text(content),
              actions: [
                TextButton(onPressed: onPressed, child: Text(buttonText))
              ],
            ),
          );
        },
        barrierDismissible: barrierDismissible);
  }

  void showTextFormFieldDialog(
      {required BuildContext context,
      required String title,
      TextEditingController? controller,
      ValueChanged<String>? onChanged,
      required String labelText,
      String? errorText,
      TextInputType keyboardType = TextInputType.text,
      required VoidCallback onPressed,
      required String buttonText}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            content: TextFormField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                    labelText: labelText,
                    border: const OutlineInputBorder(),
                    errorText: errorText),
                keyboardType: keyboardType),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('취소')),
              TextButton(onPressed: onPressed, child: Text(buttonText))
            ],
          );
        });
  }
}
