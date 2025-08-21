// ignore_for_file: prefer_const_constructors, sort_child_properties_last, invalid_use_of_protected_member, sized_box_for_whitespace, deprecated_member_use, unrelated_type_equality_checks, avoid_unnecessary_containers, unused_import, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert_vietnamese/convert_vietnamese.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/components/custom_button.dart';
import 'package:friendly_card_teacher/components/custom_search_field.dart';
import 'package:friendly_card_teacher/components/custom_text_field.dart';
import 'package:friendly_card_teacher/controllers/main_controller.dart';
import 'package:friendly_card_teacher/controllers/question_controller.dart';
import 'package:friendly_card_teacher/controllers/teacher_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/controllers/vocabulary_controller.dart';
import 'package:friendly_card_teacher/models/topic.dart';
import 'package:friendly_card_teacher/models/vocabulary.dart';
import 'package:friendly_card_teacher/utils/tool.dart';
import 'package:friendly_card_teacher/widget/empty_data.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:friendly_card_teacher/models/users.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker_web/image_picker_web.dart';
// import 'package:flutter/foundation.dart' show  kIsWeb;

class TopicManagmentScreen extends StatelessWidget {
  const TopicManagmentScreen({super.key});
  void loadData(
    RxList<Topic> listTopic,
    Rx<TextEditingController> searchController,
  ) {
    TopicController topicController = Get.find<TopicController>();
    listTopic.value = topicController.listTopics.value
        .where(
          (item) => removeDiacritics(item.name.toUpperCase()).contains(
            removeDiacritics(searchController.value.text.toUpperCase()),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();
    TopicController topicController = Get.find<TopicController>();

    Rx<TextEditingController> searchController = TextEditingController().obs;

    RxList<Topic> listTopic = <Topic>[].obs;

    RxInt currentPage = 0.obs;
    // if (usersController.user.value.role == 'teacher') {
    //   topicController.loadTopicTeacher();
    // }

    RxInt offset = 0.obs;
    RxInt limit = 6.obs;

    return Obx(() {
      loadData(listTopic, searchController);
      return usersController.loading.value || topicController.loading.value
          ? const LoadingPage()
          : Scaffold(
              body: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: Get.width * 0.6,
                          child: CustomSearchFiled(
                            hint: 'Tìm kiếm chủ đề theo Tên chủ đề.',
                            onChanged: (String value) {
                              loadData(listTopic, searchController);
                            },
                            controller: searchController.value,
                          ),
                        ),
                        Container(
                          width: Get.width * 0.05,
                          child: IconButton(
                            onPressed: () async {
                              topicController.loading.value = true;
                              searchController.value.clear();
                              if (usersController.user.value.role == 'admin') {
                                await topicController.loadAllTopic();
                              } else {
                                await topicController.loadTopicTeacher();
                              }
                              loadData(listTopic, searchController);
                              topicController.loading.value = false;
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: AppColor.lightBlue,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                AppColor.blue,
                              ),
                            ),
                          ),
                        ),
                        usersController.user.value.role == 'teacher'
                            ? Container(
                                width: Get.width * 0.2,
                                decoration: BoxDecoration(),
                                child: CustomButton(
                                  title: 'Thêm chủ đề',
                                  bgColor: AppColor.blue,
                                  onClicked: () async {
                                    topicController.topic.value =
                                        Topic.initTopic();
                                    await formTopic();
                                  },
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  Divider(),
                  listTopic.value
                          .where(
                            (item) =>
                                item.status ==
                                Tool.listStatus[currentPage.value]['value'],
                          )
                          .isEmpty
                      ? EmptyData()
                      : Expanded(
                          child: FlexibleGridView(
                            axisCount: GridLayoutEnum.threeElementsInRow,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children: listTopic.value
                                .getRange(
                                  offset.value * limit.value,
                                  (offset.value + 1) * limit.value >=
                                          listTopic.value.length
                                      ? listTopic.value.length
                                      : (offset.value + 1) * limit.value,
                                )
                                .where(
                                  (item) =>
                                      item.status ==
                                      Tool.listStatus[currentPage
                                          .value]['value'],
                                )
                                .map((item) => topicItem(context, item))
                                .toList(),
                          ),
                        ),
                ],
              ),
              floatingActionButton: Container(
                width: Get.width * 0.975,
                height: Get.height * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    offset.value != 0
                        ? InkWell(
                            onTap: () {
                              offset.value = offset.value - 1;
                            },
                            child: Icon(Icons.arrow_left_rounded, size: 128),
                          )
                        : SizedBox(),
                    (offset.value + 1) * limit.value < listTopic.value.length
                        ? InkWell(
                            onTap: () {
                              offset.value = offset.value + 1;
                            },
                            child: Icon(Icons.arrow_right_rounded, size: 128),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              backgroundColor: AppColor.lightBlue,
              bottomNavigationBar: BottomNavigationBar(
                elevation: 15,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 16,
                unselectedFontSize: 13,
                selectedIconTheme: const IconThemeData(size: 32),
                unselectedIconTheme: const IconThemeData(size: 24),
                showUnselectedLabels: true,
                backgroundColor: AppColor.blue,
                unselectedItemColor: AppColor.labelBlue,
                unselectedLabelStyle: TextStyle(color: AppColor.labelBlue),
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                selectedItemColor: Colors.white,
                items: Tool.listStatus
                    .map(
                      (status) => BottomNavigationBarItem(
                        icon: Icon(Icons.check_circle),
                        label:
                            '${status['label']} (${listTopic.value.where((item) => item.status == status['value']).length})',
                      ),
                    )
                    .toList(),
                currentIndex: currentPage.value,
                onTap: (value) {
                  offset.value = 0;
                  currentPage.value = value;
                },
              ),
            );
    });
  }

  Container topicItem(BuildContext context, Topic item) {
    UsersController usersController = Get.find<UsersController>();
    TeacherController teacherController = Get.find<TeacherController>();
    TopicController topicController = Get.find<TopicController>();
    Users teacher = Users.initTeacher();
    if (usersController.user.value.role == 'teacher') {
      teacher = usersController.user.value;
    } else {
      teacher =
          teacherController.listTeachers.value.firstWhereOrNull(
            (t) => t.id == item.user_id,
          ) ??
          Users.initTeacher();
    }
    var itemColor =
        (Tool.listStatus.firstWhereOrNull((s) => s['value'] == item.status) ??
        Tool.listStatus[0])['color'];
    // var itemStatusLabel =
    //     (Tool.listStatus.firstWhereOrNull((s) => s['value'] == item.status) ??
    //         Tool.listStatus[0])['label'];
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Get.width * 0.03,
        vertical: Get.height * 0.05,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          topicController.topic.value = item;
          await formTopic();
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: Get.height * 0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        (item.image != '')
                            ? item.image
                            : 'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png',
                      ),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: Get.width * 0.01,
                    right: Get.width * 0.01,
                  ),
                  child: PopupMenuButton<String>(
                    child: Icon(Icons.circle, color: itemColor),
                    color: AppColor.lightBlue,
                    itemBuilder: (context) =>
                        usersController.user.value.role == 'teacher'
                        ? []
                        : item.status == 'await'
                        ? [
                            PopupMenuItem(
                              value: 'active',
                              child: ListTile(
                                leading: Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                ),
                                textColor: Colors.green,
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                title: Text('Duyệt'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'inactive',
                              child: ListTile(
                                leading: Icon(
                                  Icons.circle,
                                  color: AppColor.grey,
                                ),
                                textColor: AppColor.grey,
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                title: Text('Không duyệt'),
                              ),
                            ),
                          ]
                        : item.status == 'active'
                        ? [
                            PopupMenuItem(
                              value: 'inactive',
                              child: ListTile(
                                leading: Icon(
                                  Icons.circle,
                                  color: AppColor.grey,
                                ),
                                textColor: AppColor.grey,
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                title: Text('Không duyệt'),
                              ),
                            ),
                          ]
                        : item.status == 'inactive'
                        ? [
                            PopupMenuItem(
                              value: 'active',
                              child: ListTile(
                                leading: Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                ),
                                textColor: Colors.green,
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                title: Text('Duyệt'),
                              ),
                            ),
                          ]
                        : [],
                    onSelected: (value) async {
                      await topicController.updateTopicStatus(item, value);
                    },
                  ),
                ),
              ],
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(Get.height * 0.01),
              child: Text(
                item.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(Get.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person),
                  Text(
                    ' ${teacher.fullname}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> formTopic() async {
    TopicController topicController = Get.find<TopicController>();
    UsersController usersController = Get.find<UsersController>();
    TextEditingController nameController = TextEditingController(
      text: topicController.topic.value.name,
    );
    final formKey = GlobalKey<FormState>();

    RxString filePath = ''.obs;
    RxString imgUrl = topicController.topic.value.image.obs;

    await Get.dialog(
      Obx(
        () => AlertDialog(
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
          title: Column(
            children: [
              Text(
                'Thông tin chủ đề',
                style: TextStyle(
                  fontSize: 28,
                  color: AppColor.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: AppColor.blue),
            ],
          ),
          content: Container(
            width: Get.width * 0.5,
            height: Get.height * 0.3,
            child: Form(
              key: formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      // padding: const EdgeInsets.all(8.0),
                      child: CustomTextField(
                        label: 'Tên chủ đề',
                        controller: nameController,
                        required: true,
                        readOnly: usersController.user.value.role != 'teacher',
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: usersController.user.value.role != 'teacher'
                              ? null
                              : () async {
                                  var result = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (result != null) {
                                    filePath.value = result.path;
                                  }
                                },
                          child: Container(
                            height: Get.height * 0.25,
                            width: Get.height * 0.25,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              // border: Border.all(),
                              borderRadius: BorderRadius.all(
                                Radius.circular(32),
                              ),
                              image: topicController.topic.value.id == ''
                                  ? filePath.value == ''
                                        ? null
                                        : DecorationImage(
                                            image: FileImage(
                                              File(filePath.value),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                  : filePath.value == ''
                                  ? imgUrl.value == ''
                                        ? null
                                        : DecorationImage(
                                            image: NetworkImage(imgUrl.value),
                                            fit: BoxFit.cover,
                                          )
                                  : DecorationImage(
                                      image: FileImage(File(filePath.value)),
                                      fit: BoxFit.cover,
                                    ),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      usersController.user.value.role == 'teacher'
                          ? Text(
                              'Nhấn vào đây để thay đổi ảnh chủ đề.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppColor.labelBlue,
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Column(
              children: [
                Divider(color: AppColor.blue),
                Row(
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
                    usersController.user.value.role == 'teacher' &&
                            topicController.topic.value.status != 'active'
                        ? Row(
                            children: [
                              SizedBox(width: 64),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    AppColor.blue,
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    topicController.topic.value.name =
                                        nameController.text;
                                    topicController.topic.value.user_id =
                                        usersController.user.value.id;
                                    topicController.topic.value.status =
                                        'await';
                                    topicController.topic.value.update_at =
                                        Timestamp.now();
                                    Get.back();
                                    if (topicController.topic.value.id == '') {
                                      await topicController.createTopic(
                                        filePath.value,
                                      );
                                    } else {
                                      await topicController.updateTopic(
                                        filePath.value,
                                      );
                                    }
                                  }
                                },
                                child: Text('Xác nhận'),
                              ),
                            ],
                          )
                        : SizedBox(),
                    topicController.topic.value.id != ''
                        ? Row(
                            children: [
                              SizedBox(width: 64),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    AppColor.blue,
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  Get.back();
                                  topicController.loading.value = true;
                                  await Get.find<VocabularyController>()
                                      .loadVocabularyTopic();
                                  topicController.loading.value = false;
                                  Get.toNamed('/vocabulary');
                                },
                                child: Text('Từ vựng'),
                              ),
                              SizedBox(width: 64),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    AppColor.blue,
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  Get.back();
                                  topicController.loading.value = true;
                                  await Get.find<QuestionController>()
                                      .loadQuestionData();
                                  topicController.loading.value = false;
                                  Get.toNamed('/question');
                                },
                                child: Text('Câu hỏi'),
                              ),
                            ],
                          )
                        : SizedBox(),
                    usersController.user.value.role == 'admin'
                        ? topicController.topic.value.status == 'active'
                              ? btnActive()
                              : topicController.topic.value.status == 'inactive'
                              ? btnInactive()
                              : btnAwait()
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget btnActive() {
    return Row(
      children: [
        buttonStatus({
          'label': 'Không duyệt',
          'value': 'inactive',
          'color': AppColor.grey,
        }),
      ],
    );
  }

  Widget btnInactive() {
    return Row(
      children: [
        buttonStatus({
          'label': 'Duyệt',
          'value': 'active',
          'color': AppColor.green,
        }),
      ],
    );
  }

  Widget btnAwait() {
    return Row(
      children: [
        buttonStatus({
          'label': 'Duyệt',
          'value': 'active',
          'color': AppColor.green,
        }),
        buttonStatus({
          'label': 'Không duyệt',
          'value': 'inactive',
          'color': AppColor.grey,
        }),
      ],
    );
  }

  Widget buttonStatus(Map<String, dynamic> stt) {
    TopicController topicController = Get.find<TopicController>();
    return Row(
      children: [
        SizedBox(width: 64),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(stt['color']),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          onPressed: () async {
            Get.back();
            await topicController.updateTopicStatus(
              topicController.topic.value,
              stt['value'],
            );
          },
          child: Text(stt['label']),
        ),
      ],
    );
  }
}
