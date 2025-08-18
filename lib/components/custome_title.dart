// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({super.key, required this.title, this.textStyle});

  final String title;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Get.height * 0.02),
      child: Text(
        title.toUpperCase(),
        style: textStyle ??
            const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
