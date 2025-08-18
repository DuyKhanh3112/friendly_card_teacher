// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, invalid_use_of_protected_member, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/components/custom_button.dart';
import 'package:friendly_card_teacher/components/custom_dialog.dart';
import 'package:friendly_card_teacher/components/custom_text_field.dart';
import 'package:friendly_card_teacher/controllers/teacher_controller.dart';
import 'package:friendly_card_teacher/models/teacher_info.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';

class TeacherFormScreen extends StatelessWidget {
  const TeacherFormScreen({super.key});
  @override
  Widget build(BuildContext context) {
    TeacherController teacherController = Get.find<TeacherController>();

    TextEditingController fullnameController = TextEditingController(
      text: teacherController.teacher.value.fullname,
    );
    TextEditingController usernameController = TextEditingController(
      text: teacherController.teacher.value.username,
    );
    TextEditingController phonenameController = TextEditingController(
      text: teacherController.teacher.value.phone,
    );
    TextEditingController emailnameController = TextEditingController(
      text: teacherController.teacher.value.email,
    );

    final formKey = GlobalKey<FormState>();
    RxList<XFile> listFile = <XFile>[].obs;
    RxList<TeacherInfo> listTeacherInfo = <TeacherInfo>[].obs;
    listTeacherInfo.value = [];
    listTeacherInfo.value.addAll(teacherController.listTeacherInfo.value);

    return Obx(() {
      return teacherController.loading.value
          ? const LoadingPage()
          : SafeArea(
              child: Scaffold(
                backgroundColor: AppColor.lightBlue,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    teacherController.teacher.value.id == ''
                        ? 'Thêm giáo viên chuyên môn'
                        : 'Cập nhật thông tin giáo viên chuyên môn',
                  ),
                  backgroundColor: AppColor.blue,
                  foregroundColor: Colors.white,
                  titleTextStyle: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                body: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.05,
                      vertical: Get.height * 0.05,
                    ),
                    margin: EdgeInsets.symmetric(vertical: Get.height * 0.05),
                    width: Get.width * 0.65,
                    // height: Get.height * 0.8,
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
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: CustomTextField(
                              label: 'Tên tài khoản',
                              required: true,
                              readOnly:
                                  teacherController.teacher.value.id != '',
                              controller: usernameController,
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: CustomTextField(
                              label: 'Họ tên',
                              required: true,
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
                              required: true,
                              controller: phonenameController,
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: CustomTextField(
                              label: 'Email',
                              required: true,
                              type: ContactType.mail,
                              controller: emailnameController,
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
                                text: 'Giáo viên',
                              ),
                            ),
                          ),
                          teacherController.teacher.value.id == ''
                              ? SizedBox()
                              : Container(
                                  width: Get.width * 0.4,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Get.width * 0.05,
                                  ),
                                  child: CustomTextField(
                                    label: 'Trạng thái',
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text:
                                          teacherController.teacher.value.active
                                          ? 'Đang hoạt động'
                                          : 'Đã bị khóa',
                                    ),
                                  ),
                                ),
                          teacherController.teacher.value.active
                              ? SizedBox()
                              : Container(
                                  width: Get.width * 0.4,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Get.width * 0.05,
                                  ),
                                  child: CustomTextField(
                                    label: 'Lý do bị khóa',
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text:
                                          teacherController
                                              .teacher
                                              .value
                                              .reason_lock ??
                                          '',
                                    ),
                                  ),
                                ),

                          Container(
                            // width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: Get.width * 0.1,
                                  child: Text(
                                    'Văn bằng/Chứng chỉ: ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.labelBlue,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: Get.width * 0.2,
                                  padding: EdgeInsets.all(12),
                                  margin: EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      ...listTeacherInfo.map(
                                        (info) => Container(
                                          width: Get.width * 0.8,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  listTeacherInfo.removeWhere(
                                                    (i) => i.id == info.id,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.cancel,
                                                  color: AppColor.error,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  teacherController
                                                          .loading
                                                          .value =
                                                      true;
                                                  await OpenFilex.open(
                                                    info.attachments,
                                                  );
                                                  teacherController
                                                          .loading
                                                          .value =
                                                      false;
                                                  return;
                                                },
                                                child: Container(
                                                  width: Get.width * 0.15,
                                                  child: Text(
                                                    info.name,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColor.blue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ...listFile.map(
                                        (file) => Container(
                                          width: Get.width * 0.8,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  listFile.remove(file);
                                                },
                                                child: Icon(
                                                  Icons.cancel,
                                                  color: AppColor.error,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  teacherController
                                                          .loading
                                                          .value =
                                                      true;
                                                  await OpenFilex.open(
                                                    file.path,
                                                  );
                                                  teacherController
                                                          .loading
                                                          .value =
                                                      false;
                                                  return;
                                                },
                                                child: Container(
                                                  width: Get.width * 0.15,
                                                  child: Text(
                                                    file.name,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColor.blue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      var result = await FilePicker.platform
                                          .pickFiles(allowMultiple: true);
                                      if (result != null) {
                                        listFile.value = listFile.value
                                            .where((test) => true)
                                            .toList();
                                        for (var file in result.files) {
                                          listFile.value.add(file.xFile);
                                        }
                                      } else {
                                        // User canceled the picker
                                      }
                                    },
                                    child: Text('Chọn file'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            // width: Get.width * 0.4,
                            padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.05,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: Get.width * 0.45,
                                  child: CustomButton(
                                    title: 'Lưu giáo viên',
                                    onClicked: () async {
                                      if (formKey.currentState!.validate()) {
                                        teacherController
                                                .teacher
                                                .value
                                                .fullname =
                                            fullnameController.text;
                                        teacherController.teacher.value.phone =
                                            phonenameController.text;
                                        teacherController.teacher.value.email =
                                            emailnameController.text;
                                        teacherController
                                                .teacher
                                                .value
                                                .username =
                                            usernameController.text;
                                        if (teacherController
                                                .teacher
                                                .value
                                                .id ==
                                            '') {
                                          await teacherController.createTeacher(
                                            listFile.value,
                                          );
                                          showAlertDialog(
                                            context,
                                            DialogType.success,
                                            'Tạo tài khoản giáo viên thành công',
                                            '',
                                          );
                                          usernameController.clear();
                                          fullnameController.clear();
                                          phonenameController.clear();
                                          emailnameController.clear();
                                          listFile.value = [];
                                        } else {
                                          await teacherController.updateTeacher(
                                            teacherController.teacher.value,
                                            listFile.value,
                                            listTeacherInfo.value,
                                          );
                                        }
                                        listFile.value = [];
                                        listTeacherInfo.value = [];
                                        listTeacherInfo.value.addAll(
                                          teacherController
                                              .listTeacherInfo
                                              .value,
                                        );
                                      }
                                    },
                                    bgColor: AppColor.blue,
                                  ),
                                ),
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
