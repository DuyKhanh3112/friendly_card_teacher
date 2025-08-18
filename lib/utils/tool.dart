import 'dart:convert';

import 'package:friendly_card_teacher/utils/app_color.dart';

class Tool {
  static List<Map<String, dynamic>> listStatus = [
    {'value': 'await', 'label': 'Chờ duyệt', 'color': AppColor.warm},
    {'value': 'active', 'label': 'Đã duyệt', 'color': AppColor.green},
    {'value': 'inactive', 'label': 'Không duyệt', 'color': AppColor.grey},
  ];

  static String extractJsonArray(String input) {
    final regex = RegExp(r'```json\s*(\[.*?\])\s*```', dotAll: true);
    final match = regex.firstMatch(input);
    if (match != null) {
      return match.group(1)!;
    }
    return '[]';
  }

  static List<Map<String, dynamic>> parseList(String rawText) {
    final jsonArrayString = extractJsonArray(rawText);
    final parsed = json.decode(jsonArrayString);
    return List<Map<String, dynamic>>.from(parsed);
  }

  static String convertNumberToChar(int num) {
    List<String> listChar = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ];
    return num >= listChar.length ? '' : listChar[num];
  }

  // static String getLabelStatus(String status) {
  //   if (status == 'await') {
  //     return 'Đang chờ duyệt';
  //   }
  //   return '';
  // }
}
