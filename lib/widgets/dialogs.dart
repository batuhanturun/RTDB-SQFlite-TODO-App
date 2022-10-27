import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    duration: const Duration(seconds: 2),
    elevation: 10,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(5),
      topRight: Radius.circular(5),
    )),
    backgroundColor: Colors.purple,
    content: Text(message),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
