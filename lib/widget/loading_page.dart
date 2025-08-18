// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/logo_icon.png'),
                height: 100,
              ),
              SpinKitDualRing(color: AppColor.blue, size: 130),
            ],
          ),
          Text(
            'Đang xử lý ...',
            style: TextStyle(fontSize: 20, color: AppColor.blue),
          ),
        ],
      ),
    );
  }
}
