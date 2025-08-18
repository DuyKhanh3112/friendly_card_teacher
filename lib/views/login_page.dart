// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/components/custom_button.dart';
import 'package:friendly_card_teacher/components/custom_dialog.dart';
import 'package:friendly_card_teacher/components/custom_text_field.dart';
import 'package:friendly_card_teacher/controllers/main_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();

    final formKey = GlobalKey<FormState>();
    Rx<TextEditingController> usernameController = TextEditingController().obs;
    Rx<TextEditingController> passwordController = TextEditingController().obs;

    return Obx(() {
      return usersController.loading.value
          ? const LoadingPage()
          : SafeArea(
              child: Scaffold(
                backgroundColor: AppColor.lightBlue,
                body: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: Get.height * 0.75,
                      minHeight: Get.height * 0.3,
                    ),
                    width: Get.width * 0.4,
                    alignment: Alignment.center,
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
                    child: Container(
                      width: Get.width * 0.3,
                      alignment: Alignment.center,
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: Get.height * 0.15,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.02,
                              ),
                              child: Text(
                                'Chào mừng bạn đến với FriendlyCard.\n Vui lòng đăng nhập để truy cập hệ thống.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.blue,
                                ),
                              ),
                            ),
                            CustomTextField(
                              label: 'Tài khoản',
                              onChanged: (value) {
                                usernameController.value.text = value;
                              },
                              required: true,
                            ),
                            CustomTextField(
                              label: 'Mật khẩu',
                              onChanged: (value) {
                                passwordController.value.text = value;
                              },
                              required: true,
                              isPassword: true,
                            ),
                            InkWell(
                              onTap: () async {
                                await formForgotPass(context);
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                  right: Get.width * 0.01,
                                ),
                                child: Text(
                                  'Quên mật khẩu ?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.blue,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            CustomButton(
                              title: 'Đăng nhập',
                              bgColor: AppColor.blue,
                              textColor: Colors.white,
                              onClicked: () async {
                                if (formKey.currentState!.validate()) {
                                  bool res = await usersController.login(
                                    usernameController.value.text,
                                    passwordController.value.text,
                                  );
                                  if (!res) {
                                    if (usersController.user.value.id == '') {
                                      await showAlertDialog(
                                        context,
                                        DialogType.error,
                                        'Đăng nhập không thành công!',
                                        'Tài khoản hoặc mật khẩu không đúng.',
                                      );
                                      return;
                                    }
                                    if (!usersController.user.value.active) {
                                      await showAlertDialog(
                                        context,
                                        DialogType.error,
                                        'Đăng nhập không thành công!',
                                        'Tài khoản đã bị khóa.\nLý do bị khóa: ${usersController.user.value.reason_lock ?? ''}.\nVui lòng liên hệ quản trị viên để kích hoạt lại tài khoản.',
                                      );
                                      return;
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Future<void> formForgotPass(BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    TextEditingController unameController = TextEditingController();

    final keyForgotPassword = GlobalKey<FormState>();

    UsersController usersController = Get.find<UsersController>();
    await Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.lightBlue,
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
        title: Container(
          // padding: EdgeInsets.symmetric(
          //   horizontal: Get.width * 0.01,
          // ),
          // width: Get.width * 0.5,
          // height: Get.height * 0.5,
          child: Column(
            children: [
              Text(
                'Quên mật khẩu',
                style: TextStyle(
                  fontSize: 28,
                  color: AppColor.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: AppColor.blue),
            ],
          ),
        ),
        content: Container(
          width: Get.width * 0.3,
          height: Get.height * 0.25,
          child: Form(
            key: keyForgotPassword,
            child: ListView(
              children: [
                CustomTextField(
                  label: 'Tên tài khoản',
                  controller: unameController,
                  // hint: 'Nhập tên tài khoản',
                  required: true,
                  // widthPrefix: Get.width * 0.075,
                ),
                CustomTextField(
                  label: 'Email',
                  required: true,
                  controller: emailController,
                  // hint: 'Nhập email',
                  type: ContactType.mail,
                  // widthPrefix: Get.width * 0.075,
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
                alignment: Alignment.center,
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
                        if (keyForgotPassword.currentState!.validate()) {
                          if (await usersController.checkUsernameEmail(
                            unameController.text,
                            emailController.text,
                          )) {
                            Get.back();
                            await formOTP(context);
                          } else {
                            showAlertDialog(
                              context,
                              DialogType.error,
                              'Quên mật khẩu không thành công',
                              'Tên tài khoản và email không đúng. Vui lòng nhập lại tên tài khoản và email',
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
}
