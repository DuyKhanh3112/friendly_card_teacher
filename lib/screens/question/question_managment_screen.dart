// ignore_for_file: invalid_use_of_protected_member, avoid_unnecessary_containers, sized_box_for_whitespace, deprecated_member_use, sort_child_properties_last, prefer_const_constructors
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/components/custom_button.dart';
import 'package:friendly_card_teacher/components/custom_dialog.dart';
import 'package:friendly_card_teacher/components/custom_dropdown.dart';
import 'package:friendly_card_teacher/components/custom_text_field.dart';
import 'package:friendly_card_teacher/controllers/question_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/models/option.dart';
import 'package:friendly_card_teacher/models/question.dart';
import 'package:friendly_card_teacher/models/question_type.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:friendly_card_teacher/utils/tool.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:get/get.dart';

class QuestionManagementScreen extends StatelessWidget {
  const QuestionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TopicController topicController = Get.find<TopicController>();
    QuestionController questionController = Get.find<QuestionController>();
    RxList<Question> listQuestion = <Question>[].obs;

    RxInt currentPage = 0.obs;
    RxInt offset = 0.obs;
    RxInt limit = 6.obs;
    return Obx(() {
      listQuestion.value = questionController.listQuestion.value
          .where(
            (item) =>
                item.status == Tool.listStatus[currentPage.value]['value'],
          )
          .toList();
      return questionController.loading.value
          ? const LoadingPage()
          : SafeArea(
              child: Scaffold(
                backgroundColor: AppColor.lightBlue,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    'Câu hỏi thuộc chủ đề: ${topicController.topic.value.name}',
                  ),
                  backgroundColor: AppColor.blue,
                  foregroundColor: Colors.white,
                  titleTextStyle: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                body: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.025,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              Get.find<UsersController>().user.value.role ==
                                  'teacher'
                              ? [
                                  Container(width: Get.width * 0.4),
                                  Container(
                                    width: Get.width * 0.05,
                                    padding: EdgeInsets.symmetric(
                                      vertical: Get.height * 0.02,
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        await questionController
                                            .loadQuestionData();
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: AppColor.lightBlue,
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                              AppColor.blue,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: Get.width * 0.2,
                                    decoration: const BoxDecoration(),
                                    child: CustomButton(
                                      title: 'Thêm câu hỏi',
                                      bgColor: AppColor.blue,
                                      onClicked: () async {
                                        questionController.question.value =
                                            Question.initQuestion();
                                        await formQuestion(context);
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: Get.width * 0.2,
                                    decoration: const BoxDecoration(),
                                    child: CustomButton(
                                      title: 'Tạo câu hỏi tự động',
                                      bgColor: AppColor.blue,
                                      onClicked: () async {
                                        final formKey = GlobalKey<FormState>();
                                        TextEditingController numController =
                                            TextEditingController(text: '5');
                                        await Get.dialog(
                                          AlertDialog(
                                            titlePadding: EdgeInsets.symmetric(
                                              horizontal: Get.width * 0.025,
                                              vertical: Get.width * 0.01,
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: Get.width * 0.025,
                                                  // vertical: Get.width * 0.01,
                                                ),
                                            buttonPadding: EdgeInsets.symmetric(
                                              horizontal: Get.width * 0.025,
                                              vertical: Get.width * 0.01,
                                            ),
                                            actionsPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: Get.width * 0.025,
                                                  vertical: Get.width * 0.01,
                                                ),
                                            title: Column(
                                              children: [
                                                Text(
                                                  'Số câu hỏi tạo tự động cho mỗi loại câu hỏi',
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
                                              // width: Get.width * 0.5,
                                              // height: Get.height * 0.3,
                                              child: Form(
                                                key: formKey,
                                                child: CustomTextField(
                                                  controller: numController,
                                                  label: 'Số câu hỏi',
                                                  required: true,
                                                  type: ContactType.number,
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              Column(
                                                children: [
                                                  Divider(color: AppColor.blue),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStatePropertyAll(
                                                                Colors.red,
                                                              ),
                                                          foregroundColor:
                                                              WidgetStatePropertyAll(
                                                                Colors.white,
                                                              ),
                                                        ),
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        child: Text('Đóng'),
                                                      ),
                                                      SizedBox(width: 64),
                                                      ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStatePropertyAll(
                                                                AppColor.blue,
                                                              ),
                                                          foregroundColor:
                                                              WidgetStatePropertyAll(
                                                                Colors.white,
                                                              ),
                                                        ),
                                                        onPressed: () async {
                                                          if (formKey
                                                              .currentState!
                                                              .validate()) {
                                                            Get.back();
                                                            await questionController
                                                                .generateQuestion(
                                                                  int.parse(
                                                                    numController
                                                                        .text,
                                                                  ),
                                                                );
                                                          }
                                                        },
                                                        child: Text('Xác nhận'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ]
                              : [
                                  Container(width: Get.width * 0.4),
                                  Container(
                                    width: Get.width * 0.05,
                                    padding: EdgeInsets.symmetric(
                                      vertical: Get.height * 0.02,
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        await questionController
                                            .loadQuestionData();
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: AppColor.lightBlue,
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                              AppColor.blue,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.025,
                        ),
                        child: Divider(color: AppColor.blue),
                      ),
                      Expanded(
                        child: FlexibleGridView(
                          axisCount: GridLayoutEnum.twoElementsInRow,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: listQuestion.value
                              .getRange(
                                offset.value * limit.value,
                                (offset.value + 1) * limit.value <
                                        listQuestion.value.length
                                    ? (offset.value + 1) * limit.value
                                    : listQuestion.value.length,
                              )
                              .map((item) {
                                return questionItem(item, context);
                              })
                              .toList(),
                        ),
                      ),
                    ],
                  ),
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
                      (offset.value + 1) * limit.value <
                              listQuestion.value.length
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
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  selectedItemColor: Colors.white,
                  items: Tool.listStatus
                      .map(
                        (status) => BottomNavigationBarItem(
                          icon: Icon(Icons.check_circle),
                          label:
                              '${status['label']} (${questionController.listQuestion.value.where((item) => item.status == status['value']).length})',
                        ),
                      )
                      .toList(),
                  currentIndex: currentPage.value,
                  onTap: (value) {
                    currentPage.value = value;
                  },
                ),
              ),
            );
    });
  }

  Widget questionItem(Question item, BuildContext context) {
    QuestionController questionController = Get.find<QuestionController>();
    List<Option> listOption = questionController.listOption
        .where((opt) => opt.question_id == item.id)
        .toList();
    var itemColor =
        (Tool.listStatus.firstWhereOrNull((s) => s['value'] == item.status) ??
        Tool.listStatus[0])['color'];

    return Stack(
      alignment: Alignment.topRight,
      children: [
        InkWell(
          onTap: () async {
            questionController.question.value = item;
            await formQuestion(context);
          },
          child: Container(
            // width: Get.width * 0.8,
            alignment: Alignment.topLeft,
            margin: EdgeInsets.symmetric(
              vertical: Get.height * 0.02,
              horizontal: Get.width * 0.02,
            ),
            padding: EdgeInsets.symmetric(
              vertical: Get.height * 0.02,
              horizontal: Get.width * 0.01,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  item.content,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColor.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '(${item.mean})',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColor.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Divider(color: AppColor.blue),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: listOption
                      .map(
                        (opt) => Container(
                          child: Text(
                            '${Tool.convertNumberToChar(listOption.indexOf(opt))}. ${opt.content}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColor.blue,
                              fontWeight: opt.is_correct
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              decoration: opt.is_correct
                                  ? TextDecoration.underline
                                  : null,
                              decorationColor: AppColor.blue,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            vertical: Get.height * 0.02,
            horizontal: Get.width * 0.02,
          ),
          padding: EdgeInsets.symmetric(
            vertical: Get.height * 0.02,
            horizontal: Get.width * 0.01,
          ),
          child: PopupMenuButton<String>(
            child: Icon(Icons.circle, color: itemColor),
            color: AppColor.lightBlue,
            itemBuilder: (context) =>
                Get.find<UsersController>().user.value.role == 'teacher'
                ? []
                : item.status == 'await'
                ? [
                    PopupMenuItem(
                      value: 'active',
                      child: ListTile(
                        leading: Icon(Icons.circle, color: Colors.green),
                        textColor: Colors.green,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        title: Text('Duyệt'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'inactive',
                      child: ListTile(
                        leading: Icon(Icons.circle, color: Colors.grey),
                        textColor: Colors.grey,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        title: Text('Không duyệt'),
                      ),
                    ),
                  ]
                : item.status == 'active'
                ? [
                    PopupMenuItem(
                      value: 'inactive',
                      child: ListTile(
                        leading: Icon(Icons.circle, color: Colors.grey),
                        textColor: Colors.grey,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        title: Text('Không duyệt'),
                      ),
                    ),
                  ]
                : item.status == 'inactive'
                ? [
                    PopupMenuItem(
                      value: 'active',
                      child: ListTile(
                        leading: Icon(Icons.circle, color: Colors.green),
                        textColor: Colors.green,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        title: Text('Duyệt'),
                      ),
                    ),
                  ]
                : [],

            onSelected: (value) async {
              await questionController.updateStatusQuestion(item, value);
            },
          ),
        ),
      ],
    );
  }

  Future<void> formQuestion(BuildContext context) async {
    QuestionController questionController = Get.find<QuestionController>();
    UsersController usersController = Get.find<UsersController>();
    final formKey = GlobalKey<FormState>();

    TextEditingController contenController = TextEditingController(
      text: questionController.question.value.content,
    );
    TextEditingController meanContentController = TextEditingController(
      text: questionController.question.value.mean,
    );

    Rx<QuestionType> questionType =
        (questionController.listQuestionType.value.firstWhereOrNull(
                  (type) =>
                      type.id ==
                      questionController.question.value.question_type_id,
                ) ??
                QuestionType.initQuestionType())
            .obs;
    RxList<Rx<Option>> listOption = <Rx<Option>>[
      Option.initOption().obs,
      Option.initOption().obs,
      Option.initOption().obs,
      Option.initOption().obs,
    ].obs;
    if (questionController.question.value.id != '') {
      listOption.value = questionController.listOption.value
          .where(
            (opt) => opt.question_id == questionController.question.value.id,
          )
          .map((opt) => opt.obs)
          .toList();
      if (listOption.isEmpty) {
        var newOpt = Option.initOption().obs;
        newOpt.value.question_id = questionController.question.value.id;
        listOption.value = [newOpt, newOpt, newOpt, newOpt];
      }
    }

    await Get.dialog(
      Obx(() {
        return AlertDialog(
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
                'Thông tin câu hỏi',
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
            // height: Get.height * 0.3,
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  Container(
                    // width: Get.width * 0.3,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Nội dung',
                          multiLines: true,
                          controller: contenController,
                          required: true,
                          readOnly:
                              usersController.user.value.role != 'teacher',
                        ),
                        CustomTextField(
                          label: 'Nghĩa câu hỏi',
                          multiLines: true,
                          controller: meanContentController,
                          required: true,
                          readOnly:
                              usersController.user.value.role != 'teacher',
                        ),
                        CustomDropdown(
                          items: questionController.listQuestionType.value
                              .map(
                                (item) => DropdownMenuItem(
                                  child: Text(
                                    item.name,
                                    overflow: TextOverflow.ellipsis,
                                    strutStyle: StrutStyle.disabled,
                                  ),
                                  value: item,
                                ),
                              )
                              .toList(),
                          value: questionController.listQuestionType.value
                              .firstWhereOrNull(
                                (t) => t.id == questionType.value.id,
                              )
                              .obs,
                          label: 'Loại câu hỏi',
                          width: Get.width * 0.5,
                          disabled:
                              usersController.user.value.role != 'teacher',
                          onChanged: (p0) {
                            if (p0 == null) {
                              questionType.value =
                                  QuestionType.initQuestionType();
                            } else {
                              questionType.value = p0;
                            }
                          },
                        ),
                        Column(
                          children: List.generate(
                            questionType.value.num_option,
                            (index) {
                              var item = listOption.value[index].value;
                              TextEditingController optController =
                                  TextEditingController(text: item.content);

                              if (questionType.value.num_option == 1) {
                                item.is_correct = true;
                              }
                              return ListTile(
                                leading: InkWell(
                                  onTap:
                                      usersController.user.value.role !=
                                          'teacher'
                                      ? null
                                      : () {
                                          item.is_correct = true;
                                          for (var element
                                              in listOption.value) {
                                            if (listOption.value.indexOf(
                                                  element,
                                                ) ==
                                                index) {
                                              element.value = item;
                                            } else {
                                              element.value.is_correct = false;
                                            }
                                          }
                                        },
                                  child: Icon(
                                    item.is_correct
                                        ? Icons.check_box_outlined
                                        : Icons.check_box_outline_blank,
                                  ),
                                ),
                                title: CustomTextField(
                                  label: questionType.value.num_option == 1
                                      ? 'Đáp án'
                                      : 'Lựa chọn ${index + 1}',
                                  controller: optController,
                                  bgColor: item.is_correct
                                      ? Colors.amber
                                      : null,
                                  required: true,
                                  readOnly:
                                      usersController.user.value.role !=
                                      'teacher',
                                  onChanged: (p0) {
                                    item.content = p0;
                                    for (var element in listOption.value) {
                                      if (listOption.value.indexOf(element) ==
                                          index) {
                                        element.value.content = p0;
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () async {
                        Get.back();
                      },
                      child: Text('Đóng'),
                    ),
                    usersController.user.value.role == 'teacher'
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
                                    if (questionType.value.id == '') {
                                      await showAlertDialog(
                                        context,
                                        DialogType.error,
                                        'Vui lòng chọn loại câu hỏi',
                                        '',
                                      );
                                      return;
                                    }
                                    if (listOption.value
                                        .where((ele) => ele.value.is_correct)
                                        .isEmpty) {
                                      await showAlertDialog(
                                        context,
                                        DialogType.error,
                                        'Vui lòng chọn lựa chọn đúng',
                                        '',
                                      );
                                      return;
                                    }

                                    questionController.question.value.content =
                                        contenController.text;
                                    questionController.question.value.mean =
                                        meanContentController.text;
                                    questionController
                                            .question
                                            .value
                                            .question_type_id =
                                        questionType.value.id;
                                    questionController.question.value.topic_id =
                                        Get.find<TopicController>()
                                            .topic
                                            .value
                                            .id;
                                    questionController
                                            .question
                                            .value
                                            .update_at =
                                        Timestamp.now();
                                    questionController.loading.value = true;
                                    Get.back();
                                    if (questionController.question.value.id ==
                                        '') {
                                      // create

                                      await questionController.createQuestion(
                                        questionController.question.value,
                                        questionType.value.num_option == 1
                                            ? [listOption.value.first.value]
                                            : listOption.value
                                                  .map((ele) => ele.value)
                                                  .toList(),
                                      );
                                    } else {
                                      // update
                                      await questionController.updateQuestion(
                                        questionController.question.value,
                                        questionType.value.num_option == 1
                                            ? [listOption.value.first.value]
                                            : listOption.value
                                                  .map((ele) => ele.value)
                                                  .toList(),
                                      );
                                    }
                                    await questionController.loadQuestionData();
                                    questionController.loading.value = false;
                                  }
                                },
                                child: Text('Xác nhận'),
                              ),
                              // questionController.question.value.id == '' ||
                              //         questionController.question.value.active
                              //     ? SizedBox()
                              //     : SizedBox(
                              //         width: 64,
                              //       ),
                              // ElevatedButton(
                              //   style: ButtonStyle(
                              //     backgroundColor:
                              //         WidgetStatePropertyAll(Colors.red),
                              //     foregroundColor:
                              //         WidgetStatePropertyAll(Colors.white),
                              //   ),
                              //   onPressed: () async {
                              //     await showComfirmDialog(
                              //       context,
                              //       'desc',
                              //       'Bạn có muốn xóa câu hỏi này không?',
                              //       () async {
                              //         Get.back();
                              //         await questionController.deletedQuestion(
                              //           questionController.question.value,
                              //         );
                              //       },
                              //     );
                              //   },
                              //   child: Text('Xóa câu hỏi'),
                              // ),
                            ],
                          )
                        : SizedBox(),
                    usersController.user.value.role == 'admin'
                        ? questionController.question.value.status == 'active'
                              ? btnActive()
                              : questionController.question.value.status ==
                                    'inactive'
                              ? btnInactive()
                              : btnAwait()
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
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
    QuestionController questionController = Get.find<QuestionController>();
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
            // await topicController.updateTopicStatus(
            //   topicController.topic.value,
            //   stt['value'],
            // );
            await questionController.updateStatusQuestion(
              questionController.question.value,
              stt['value'],
            );
          },
          child: Text(stt['label']),
        ),
      ],
    );
  }
}
