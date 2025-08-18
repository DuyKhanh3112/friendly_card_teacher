import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/controllers/main_controller.dart';
import 'package:friendly_card_teacher/controllers/overview_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

class DrawerTeacher extends StatelessWidget {
  const DrawerTeacher({super.key});

  @override
  Widget build(BuildContext context) {
    MainController mainController = Get.find<MainController>();
    UsersController usersController = Get.find<UsersController>();
    return Container(
      width: Get.width * 0.35,
      decoration: BoxDecoration(color: AppColor.lightBlue),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Container(
                //   padding: EdgeInsets.symmetric(
                //     horizontal: Get.width * 0.01,
                //     vertical: Get.height * 0.02,
                //   ),
                //   child: ListTile(
                //     leading: Image.asset(
                //       'assets/images/personal_info_icon.png',
                //       width: 64,
                //     ),
                //     title: Text(
                //       'Thông tin cá nhân',
                //       style: TextStyle(
                //         color: AppColor.blue,
                //         fontSize: 22,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //     onTap: () {
                //       mainController.numPageTeacher.value = 0;
                //       Get.back();
                //     },
                //   ),
                // ),
                SizedBox(height: Get.height * 0.05),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.01,
                    vertical: Get.height * 0.01,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        // horizontal: 5,
                        vertical: 3,
                      ),
                      child: Image.asset(
                        'assets/images/overview_icon.png',
                        width: 64,
                      ),
                    ),
                    title: Text(
                      'Tổng quan',
                      style: TextStyle(
                        color: AppColor.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      mainController.numPageTeacher.value = 0;
                      Get.back();
                      await Get.find<OverviewController>().getStatistic();
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.01,
                    vertical: Get.height * 0.01,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        // horizontal: 5,
                        vertical: 3,
                      ),
                      child: Image.asset(
                        'assets/images/topic_icon.png',
                        width: 64,
                      ),
                    ),
                    title: Text(
                      'Chủ đề',
                      style: TextStyle(
                        color: AppColor.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      mainController.numPageTeacher.value = 1;
                      Get.back();
                      await Get.find<TopicController>().loadTopicTeacher();
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.01,
                    vertical: Get.height * 0.02,
                  ),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/images/logout_icon.png',
                      width: 64,
                    ),
                    title: Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: AppColor.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      await usersController.logout();
                      // Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
