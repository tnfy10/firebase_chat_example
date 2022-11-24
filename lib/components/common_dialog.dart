import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin CommonDialog {
  void showOneButtonDialog(
      {required BuildContext context,
      required String title,
      required String content,
      String buttonText = "확인",
      required Function() onPressed,
      bool barrierDismissible = true,
      bool allowBackButton = true,
      Function(dynamic)? completeCallback}) {
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  content: Text(content),
                  actions: [TextButton(onPressed: onPressed, child: Text(buttonText))],
                ),
              );
            },
            barrierDismissible: barrierDismissible)
        .then((value) {
      if (completeCallback != null) {
        completeCallback(value);
      }
    });
  }

  void showTwoButtonDialog(
      {required BuildContext context,
      required String title,
      required String content,
      String negativeBtnText = "취소",
      required Function() onTapNegativeBtn,
      String positiveBtnText = "확인",
      required Function() onTapPositiveBtn,
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              content: Text(content),
              actions: [
                TextButton(onPressed: onTapNegativeBtn, child: Text(negativeBtnText)),
                TextButton(onPressed: onTapPositiveBtn, child: Text(positiveBtnText))
              ],
            ),
          );
        },
        barrierDismissible: barrierDismissible);
  }

  void showTextFormFieldDialog(
      {Key? key,
      required BuildContext context,
      required String title,
      TextEditingController? controller,
      ValueChanged<String>? onChanged,
      String? Function(String?)? validator,
      required String labelText,
      String? errorText,
      TextInputType keyboardType = TextInputType.text,
      required Function() onPressed,
      required String buttonText,
      bool autoFocus = true}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            content: Form(
              key: key,
              child: TextFormField(
                  controller: controller,
                  onChanged: onChanged,
                  validator: validator,
                  decoration: InputDecoration(
                      labelText: labelText,
                      border: const OutlineInputBorder(),
                      errorText: errorText),
                  keyboardType: keyboardType,
                  autofocus: autoFocus),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('취소')),
              TextButton(onPressed: onPressed, child: Text(buttonText))
            ],
          );
        });
  }
}
