// ignore_for_file: sized_box_for_whitespace

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/components/custom_button.dart';
import 'package:friendly_card_teacher/components/custom_text_field.dart';
import 'package:friendly_card_teacher/config.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UserInformationScreen extends StatelessWidget {
  const UserInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();
    Map<String, String> role =
        Config.listRole.firstWhereOrNull(
          (r) => r['value'] == usersController.user.value.role,
        ) ??
        {'value': '', 'label': ''};
    final formKey = GlobalKey<FormState>();
    TextEditingController fullnameController = TextEditingController(
      text: usersController.user.value.fullname,
    );
    TextEditingController phoneController = TextEditingController(
      text: usersController.user.value.phone,
    );
    TextEditingController emailController = TextEditingController(
      text: usersController.user.value.email,
    );

    Rx<String> filePath = ''.obs;

    return Obx(() {
      return usersController.loading.value
          ? const LoadingPage()
          : Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text('Cập nhật thông tin cá nhân'),
                backgroundColor: AppColor.blue,
                foregroundColor: Colors.white,
                titleTextStyle: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              body: SafeArea(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.05,
                      vertical: Get.height * 0.05,
                    ),
                    width: Get.width * 0.65,
                    height: Get.height * 0.8,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Form(
                      key: formKey,
                      child: ListView(
                        children: [
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: CustomTextField(
                              label: 'Tên tài khoản',
                              readOnly: true,
                              controller: TextEditingController(
                                text: usersController.user.value.username,
                              ),
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: CustomTextField(
                              label: 'Họ tên',
                              readOnly: false,
                              controller: fullnameController,
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: CustomTextField(
                              label: 'Số điện thoại',
                              readOnly: false,
                              controller: phoneController,
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: CustomTextField(
                              label: 'Email',
                              readOnly: false,
                              type: ContactType.mail,
                              controller: emailController,
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: CustomTextField(
                              label: 'Quyền',
                              readOnly: true,
                              controller: TextEditingController(
                                text: role['label'],
                              ),
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: InkWell(
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(left: 16),
                                    child: Text(
                                      'Ảnh đại diện',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: AppColor.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: filePath.value == ''
                                        ? NetworkImage(
                                            usersController.user.value.avatar ??
                                                '',
                                          )
                                        : FileImage(File(filePath.value))
                                              as ImageProvider,
                                  ),
                                  Text(
                                    '(Nhấp vào ảnh để thay đổi ảnh đại diện)',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: AppColor.blue,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),

                              onTap: () async {
                                var result = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (result != null) {
                                  filePath.value = result.path;
                                }
                              },
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: Get.width * 0.15,
                                  child: CustomButton(
                                    title: 'Lưu thông tin',
                                    onClicked: () async {
                                      if (formKey.currentState!.validate()) {
                                        usersController.user.value.fullname =
                                            fullnameController.text;
                                        usersController.user.value.phone =
                                            phoneController.text;
                                        usersController.user.value.email =
                                            emailController.text;
                                        await usersController
                                            .updateInformationUser(
                                              filePath.value,
                                            );
                                        filePath.value = '';
                                      }
                                    },
                                    bgColor: AppColor.blue,
                                  ),
                                ),
                                // Container(
                                //   width: Get.width * 0.15,
                                //   child: CustomButton(
                                //     title: 'Đổi mật khẩu',
                                //     bgColor: AppColor.blue,
                                //     onClicked: () async {},
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
    });
  }
}
