// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously

import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/components/custom_dialog.dart';
import 'package:friendly_card_teacher/components/custom_text_field.dart';
import 'package:friendly_card_teacher/controllers/cloudinary_controller.dart';
import 'package:friendly_card_teacher/controllers/main_controller.dart';
import 'package:friendly_card_teacher/controllers/overview_controller.dart';
import 'package:friendly_card_teacher/controllers/teacher_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/models/users.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  RxBool loading = false.obs;
  RxString role = ''.obs;
  Rx<Users> user = Users.initUser().obs;
  Rx<String> userId = ''.obs;

  CollectionReference usersCollection = FirebaseFirestore.instance.collection(
    'users',
  );

  bool checkLogin() {
    if (user.value.id == '' || role.value != 'teacher' || !user.value.active) {
      return false;
    }
    return true;
  }

  Future<bool> login(String uname, String pword) async {
    loading.value = true;
    user.value = Users.initUser();

    final snapshot = await usersCollection
        .where('username', isEqualTo: uname)
        .where('password', isEqualTo: pword)
        // .where('active', isEqualTo: true)
        .where('role', isEqualTo: 'teacher')
        .get();
    if (snapshot.docs.isNotEmpty) {
      Map<String, dynamic> data =
          snapshot.docs[0].data() as Map<String, dynamic>;
      data['id'] = snapshot.docs[0].id;
      user.value = Users.fromJson(data);

      role.value = user.value.role;

      if (!user.value.active) {
        loading.value = false;
        return false;
      }

      // if (role.value == 'admin') {
      //   await Get.find<MainController>().loadAllDataForAdmin();
      //   await Get.find<OverviewController>().getStatistic();
      //   Get.find<MainController>().numPageAdmin.value = 0;
      //   loading.value = false;
      //   Get.toNamed('/admin');
      // }
      if (role.value == 'teacher') {
        await Get.find<TeacherController>().loadTeacherInfo(user.value.id);
        Get.find<MainController>().numPageTeacher.value = 0;
        await Get.find<TopicController>().loadTopicTeacher();
        await Get.find<OverviewController>().getStatistic();
        loading.value = false;
        Get.toNamed('/teacher');
      }
      loading.value = false;
      return true;
    }
    loading.value = false;
    return false;
  }

  Future<void> logout() async {
    loading.value = true;
    MainController mainController = Get.find<MainController>();
    mainController.numPageAdmin.value = 0;
    user.value = Users.initUser();
    role.value = '';
    Get.toNamed('/');
    loading.value = false;
  }

  Future<void> updateInformationUser(String filePath) async {
    loading.value = true;
    user.value.update_at = Timestamp.now();
    if (filePath != '') {
      user.value.avatar = await CloudinaryController().uploadImageFile(
        filePath,
        user.value.username,
        '${user.value.role}/${user.value.username}',
      );
    }
    await usersCollection.doc(user.value.id).update(user.value.toVal());
    loading.value = false;
  }

  Future<bool> checkUsernameEmail(String username, String email) async {
    loading.value = true;
    Get.back();
    var snapshot = await usersCollection
        .where('email', isEqualTo: email)
        .where('username', isEqualTo: username)
        .where('role', isEqualTo: 'teacher')
        // .where('active', isEqualTo: true)
        .get();
    if (snapshot.docs.isEmpty) {
      loading.value = false;
      return false;
    }
    userId.value = snapshot.docs.first.id;
    unawaited(Get.find<MainController>().sendOtp(email, username));
    loading.value = false;
    return true;
  }

  Future<void> changePassword(BuildContext context) async {
    UsersController usersController = Get.find<UsersController>();
    final formKey = GlobalKey<FormState>();
    TextEditingController passwordCurrentController = TextEditingController();
    TextEditingController passwordNewController = TextEditingController();
    TextEditingController passConfController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        titlePadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          // vertical: Get.width * 0.01,
        ),
        buttonPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        actionsPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        title: Column(
          children: [
            Text(
              'Đổi mật khẩu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColor.blue,
              ),
            ),
            Divider(color: AppColor.blue),
          ],
        ),
        content: Container(
          width: Get.width * 0.35,
          height: Get.height * 0.35,
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: passwordCurrentController,
                  label: 'Mật khẩu hiện tại',
                  required: true,
                  isPassword: true,
                ),
                CustomTextField(
                  controller: passwordNewController,
                  label: 'Mật khẩu mới',
                  required: true,
                  isPassword: true,
                ),
                CustomTextField(
                  controller: passConfController,
                  label: 'Xác nhận mật khẩu',
                  required: true,
                  isPassword: true,
                ),
                user.value.role == 'admin'
                    ? SizedBox()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () async {
                            Get.back();
                            unawaited(
                              Get.find<MainController>().sendOtp(
                                usersController.user.value.email ?? '',
                                usersController.user.value.username,
                              ),
                            );
                            await usersController.formOTP(context);
                          },
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: AppColor.blue,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.blue,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        actions: [
          Column(
            children: [
              Divider(color: AppColor.blue),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                // width: Get.width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Đóng'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(AppColor.blue),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          if (passwordCurrentController.value.text !=
                              usersController.user.value.password) {
                            await showAlertDialog(
                              context,
                              DialogType.error,
                              'Đổi mật khẩu không thành công!',
                              'Mật khẩu hiện tại không đúng. Vui lòng nhập lại mật khẩu hiện tại',
                            );
                            return;
                          }
                          if (passwordNewController.text !=
                              passConfController.text) {
                            await showAlertDialog(
                              context,
                              DialogType.error,
                              'Đổi mật khẩu không thành công!',
                              'Mật khẩu mới và xác nhận mật khẩu không trùng khớp. Vui lòng xác nhận lại mật khẩu',
                            );
                            return;
                          } else {
                            Get.back();

                            // changePassword(passConfController.text);
                            await updatePassword(passConfController.text);

                            await showAlertDialog(
                              context,
                              DialogType.success,
                              'Thành công',
                              'Đổi mật khẩu thành công!',
                            );
                          }
                        }
                      },
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> formOTP(BuildContext context) async {
    MainController mainController = Get.find<MainController>();
    final formKey = GlobalKey<FormState>();
    TextEditingController numController = TextEditingController();
    await Get.dialog(
      AlertDialog(
        titlePadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          // vertical: Get.width * 0.01,
        ),
        buttonPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        actionsPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        title: Column(
          children: [
            Text(
              'Xác nhận mã OTP',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColor.blue,
              ),
            ),
            Divider(color: AppColor.blue),
          ],
        ),
        content: Container(
          width: Get.width * 0.3,
          height: Get.height * 0.25,
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: numController,
                  label: 'Mã OTP',
                  required: true,
                  type: ContactType.number,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '(Vui lòng kiểm tra email của bạn để lấy mã OTP)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.blue,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Column(
            children: [
              Divider(color: AppColor.blue),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                // width: Get.width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Đóng'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(AppColor.blue),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          if (mainController.otpCode.value ==
                              numController.text) {
                            Get.back();
                            await changePasswordForm(context);
                          } else {
                            showAlertDialog(
                              context,
                              DialogType.error,
                              'Mã OTP không đúng',
                              'Vui lòng kiểm tra lại email của bạn để lấy mã OTP',
                            );
                            numController.clear();
                          }
                        }
                      },
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> changePasswordForm(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    TextEditingController passwordController = TextEditingController();
    TextEditingController passConfController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        titlePadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          // vertical: Get.width * 0.01,
        ),
        buttonPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        actionsPadding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.025,
          vertical: Get.width * 0.01,
        ),
        title: Column(
          children: [
            Text(
              'Cập nhật mật khẩu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColor.blue,
              ),
            ),
            Divider(color: AppColor.blue),
          ],
        ),
        content: Container(
          width: Get.width * 0.3,
          height: Get.height * 0.25,
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: passwordController,
                  label: 'Mật khẩu',
                  required: true,
                  isPassword: true,
                ),
                CustomTextField(
                  controller: passConfController,
                  label: 'Xác nhận mật khẩu',
                  required: true,
                  isPassword: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Column(
            children: [
              Divider(color: AppColor.blue),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                // width: Get.width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Đóng'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(AppColor.blue),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          if (passwordController.text !=
                              passConfController.text) {
                            await showAlertDialog(
                              context,
                              DialogType.error,
                              'Cập nhật mật khẩu không thành công!',
                              'Mật khẩu không trùng khớp. Vui lòng xác nhận lại mật khẩu',
                            );
                            return;
                          } else {
                            Get.back();

                            // await usersController
                            //     .changePassword(passConfController.text);

                            await showAlertDialog(
                              context,
                              DialogType.success,
                              'Thành công',
                              'Cập nhật mật khẩu thành công!',
                            );
                          }
                        }
                      },
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> updatePassword(String password) async {
    loading.value = true;
    await usersCollection.doc(userId.value).update({'password': password});
    user.value.password = password;
    loading.value = false;
  }
}
