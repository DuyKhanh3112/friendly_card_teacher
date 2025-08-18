// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.onClicked,
    this.bgColor,
    this.textColor,
    this.icon,
  });

  final String title;
  final Future<void> Function()? onClicked;
  final Color? bgColor;
  final Color? textColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Get.height * 0.02),
      decoration: const BoxDecoration(),
      child: ElevatedButton(
        onPressed: onClicked ?? () {},
        style: ButtonStyle(
          alignment: Alignment.center,
          backgroundColor:
              MaterialStateProperty.all<Color>(bgColor ?? Colors.green),
        ),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: Get.height * 0.01),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
