// ignore_for_file: file_names, unnecessary_brace_in_string_interps

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

// enum ContactType { mail, phone }

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.width,
    this.disabled,
  });

  final void Function(dynamic) onChanged;

  final List<DropdownMenuItem> items;
  final Rx<dynamic> value;
  final String label;
  final double width;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        // padding: EdgeInsets.symmetric(vertical: Get.height * 0.02),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.blue),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.2,
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.01,
                // vertical: Get.width * 0.01,
              ),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: AppColor.labelBlue)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.labelBlue,
                ),
              ),
            ),
            Container(
              width: width * 0.7,
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.01,
                // vertical: Get.width * 0.01,
              ),
              alignment: Alignment.centerLeft,
              child: DropdownButtonHideUnderline(
                child: disabled == true
                    ? DropdownButton2(
                        items: items,
                        value: value.value,
                        hint: Text(
                          'Chọn ${label.toLowerCase()}',
                          style: TextStyle(color: AppColor.blue, fontSize: 18),
                        ),
                        style: TextStyle(color: AppColor.blue, fontSize: 18),
                        isExpanded: true,
                      )
                    : DropdownButton2(
                        items: items,
                        value: value.value,
                        onChanged: (item) {
                          value.value = item;
                          onChanged(item);
                        },
                        hint: Text(
                          'Chọn ${label.toLowerCase()}',
                          style: TextStyle(color: AppColor.blue, fontSize: 18),
                        ),
                        style: TextStyle(color: AppColor.blue, fontSize: 18),
                        isExpanded: true,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
