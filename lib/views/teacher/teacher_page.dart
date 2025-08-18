// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/controllers/main_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/views/teacher/drawer_teacher.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key});
  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();
    MainController mainController = Get.find<MainController>();

    return Obx(() {
      return usersController.loading.value
          ? const LoadingPage()
          : SafeArea(
              child: Scaffold(
                backgroundColor: AppColor.lightBlue,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    mainController.titleTeacher[mainController
                        .numPageTeacher
                        .value],
                  ),
                  backgroundColor: AppColor.blue,
                  titleTextStyle: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  foregroundColor: Colors.white,
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'logout') {
                          await usersController.logout();
                          return;
                        }
                        if (value == 'profile') {
                          Get.toNamed('/person_info');
                          return;
                        }
                        if (value == 'change_pass') {
                          usersController.changePassword(context);
                          return;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'profile',
                          labelTextStyle: WidgetStatePropertyAll(
                            TextStyle(
                              fontSize: 18,
                              color: AppColor.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/personal_info_icon.png',
                                width: 32,
                              ),
                              const SizedBox(width: 16),
                              const Text('Thông tin cá nhân'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'change_pass',
                          labelTextStyle: WidgetStatePropertyAll(
                            TextStyle(
                              fontSize: 18,
                              color: AppColor.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/personal_info_icon.png',
                                width: 32,
                              ),
                              const SizedBox(width: 16),
                              const Text('Đổi mật khẩu'),
                            ],
                          ),
                        ),

                        PopupMenuItem<String>(
                          value: 'logout',
                          labelTextStyle: WidgetStatePropertyAll(
                            TextStyle(
                              fontSize: 18,
                              color: AppColor.warm,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/logout_icon.png',
                                width: 32,
                              ),
                              const SizedBox(width: 16),
                              const Text('Đăng xuất'),
                            ],
                          ),
                        ),
                      ],
                      icon: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(
                              usersController.user.value.avatar ??
                                  'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png',
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          Text(
                            '${usersController.user.value.fullname} (Giáo viên)',
                            style: const TextStyle(
                              // fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down_outlined),
                        ],
                      ),
                      iconColor: Colors.white,
                      iconSize: 24,
                    ),
                  ],
                ),
                body: mainController
                    .pageTeacher[mainController.numPageTeacher.value],
                drawer: const DrawerTeacher(),
              ),
            );
    });
  }
}
