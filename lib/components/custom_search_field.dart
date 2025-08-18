// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

class CustomSearchFiled extends StatelessWidget {
  const CustomSearchFiled({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.controller,
  });

  final String hint;
  final TextEditingController controller;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Get.height * 0.02),
      decoration: const BoxDecoration(),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: 18, color: AppColor.blue),
        decoration: InputDecoration(
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.labelBlue,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
