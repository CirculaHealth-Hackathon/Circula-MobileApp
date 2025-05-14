import 'package:circulahealth/components/animated_button.dart';
import 'package:flutter/material.dart';

void showAlert(
  BuildContext context,
  String theMessage,
  String title,
  String buttonTitle,
  VoidCallback onButtonPressed,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 33.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Text(
          theMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
        actions: [
          CustomAnimatedButton(
            onButtonpressed: () {
              Navigator.pop(context);
              onButtonPressed();
            },
            buttonTitle: buttonTitle,
          )
        ],
      );
    },
  );
}
