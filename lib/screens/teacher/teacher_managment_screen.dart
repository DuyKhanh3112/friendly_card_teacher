// ignore_for_file: prefer_const_constructors, sort_child_properties_last, invalid_use_of_protected_member, sized_box_for_whitespace, deprecated_member_use, unrelated_type_equality_checks, avoid_unnecessary_containers

import 'package:convert_vietnamese/convert_vietnamese.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/components/custom_button.dart';
import 'package:friendly_card_teacher/components/custom_search_field.dart';
import 'package:friendly_card_teacher/controllers/teacher_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/widget/empty_data.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:friendly_card_teacher/models/users.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

class TeacherManagmentScreen extends StatelessWidget {
  const TeacherManagmentScreen({super.key});

  void loadData(
    RxList<Users> listTeachers,
    RxInt currentPage,
    Rx<TextEditingController> searchController,
  ) {
    TeacherController teacherController = Get.find<TeacherController>();

    listTeachers.value = teacherController.listTeachers
        .where(
          (t) =>
              (removeDiacritics(t.fullname.toLowerCase()).contains(
                removeDiacritics(searchController.value.text.toLowerCase()),
              ) ||
              removeDiacritics(t.email!.toLowerCase()).contains(
                removeDiacritics(searchController.value.text.toLowerCase()),
              ) ||
              removeDiacritics(t.phone!.toLowerCase()).contains(
                removeDiacritics(searchController.value.text.toLowerCase()),
              ) ||
              removeDiacritics(t.username.toLowerCase()).contains(
                removeDiacritics(searchController.value.text.toLowerCase()),
              )),
        )
        .toList();

    listTeachers.sort((a, b) => b.update_at.compareTo(a.update_at));
  }

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();
    TeacherController teacherController = Get.find<TeacherController>();
    Rx<TextEditingController> searchController = TextEditingController().obs;
    RxList<Users> listTeachers = <Users>[].obs;
    RxInt currentPage = 0.obs;
    if (usersController.user.value.role == 'teacher') {
      teacherController.loadAllData();
    }
    RxInt offset = 0.obs;
    RxInt limit = 6.obs;
    return Obx(() {
      // listTeachers.value = listTeachers.value
      //     .where((t) => t.active == (currentPage == 0))
      //     .toList();
      loadData(listTeachers, currentPage, searchController);
      return usersController.loading.value || teacherController.loading.value
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
                            hint:
                                'Tìm kiếm giáo viên chuyên môn theo Tên đăng nhập, Họ tên, Email, Số điện thoại.',
                            onChanged: (String value) {
                              loadData(
                                listTeachers,
                                currentPage,
                                searchController,
                              );
                            },
                            controller: searchController.value,
                          ),
                        ),
                        Container(
                          width: Get.width * 0.05,
                          child: IconButton(
                            onPressed: () async {
                              teacherController.loading.value = true;
                              searchController.value.clear();
                              await teacherController.loadAllData();
                              loadData(
                                listTeachers,
                                currentPage,
                                searchController,
                              );
                              teacherController.loading.value = false;
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
                        Container(
                          width: Get.width * 0.2,
                          decoration: BoxDecoration(),
                          child: CustomButton(
                            title: 'Thêm giáo viên',
                            bgColor: AppColor.blue,
                            onClicked: () async {
                              teacherController.teacher.value =
                                  Users.initTeacher();
                              Get.toNamed('/teacher_form');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  teacherController.listTeachers.isEmpty
                      ? EmptyData()
                      : Expanded(
                          child: FlexibleGridView(
                            axisCount: GridLayoutEnum.threeElementsInRow,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children: listTeachers.value
                                .where((t) => t.active == (currentPage == 0))
                                .toList()
                                .getRange(
                                  offset.value * limit.value,
                                  (offset.value + 1) * limit.value >=
                                          listTeachers.value
                                              .where(
                                                (t) =>
                                                    t.active ==
                                                    (currentPage == 0),
                                              )
                                              .length
                                      ? listTeachers.value
                                            .where(
                                              (t) =>
                                                  t.active ==
                                                  (currentPage == 0),
                                            )
                                            .length
                                      : (offset.value + 1) * limit.value,
                                )
                                .map((item) => itemTeacher(context, item))
                                .toList(),
                          ),
                        ),
                ],
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
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle),
                    label:
                        'Đang hoạt động (${listTeachers.where((t) => t.active).length})',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.cancel),
                    label:
                        'Đã bị khóa (${listTeachers.where((t) => !t.active).length})',
                  ),
                ],
                currentIndex: currentPage.value,
                onTap: (value) {
                  offset.value = 0;
                  currentPage.value = value;
                },
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
                            listTeachers.value
                                .where((t) => t.active == (currentPage == 0))
                                .length
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
            );
    });
  }

  Widget itemTeacher(BuildContext context, Users item) {
    TeacherController teacherController = Get.find<TeacherController>();
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
          teacherController.teacher.value = item;
          await teacherController.loadTeacherInfo(item.id);
          Get.toNamed('/teacher_form');
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
                        (item.avatar != null && item.avatar != '')
                            ? item.avatar!
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
                    child: Icon(
                      Icons.circle,
                      color: item.active ? AppColor.blue : Colors.grey,
                    ),
                    onSelected: (value) async {
                      if (value == 'active') {
                        Users teacher =
                            teacherController.listTeachers.value
                                .firstWhereOrNull((t) => t.id == item.id) ??
                            Users.initUser();
                        teacher.active = true;
                        teacher.reason_lock = '';
                        await teacherController.updateStatusTeacher(teacher);
                      } else {
                        TextEditingController reasonLockController =
                            TextEditingController();
                        final formKey = GlobalKey<FormState>();
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
                              child: Column(
                                children: [
                                  Text(
                                    'Lý do khóa tài khoản',
                                    style: TextStyle(color: AppColor.blue),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                            content: Form(
                              key: formKey,
                              child: TextFormField(
                                controller: reasonLockController,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColor.blue,
                                  // fontWeight: FontWeight.bold,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim() == '') {
                                    return 'Vui lòng nhập lý do khóa tài khoản.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Nhập lý do khóa tài khoản',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.labelBlue,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                                  errorMaxLines: 2,
                                ),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.red,
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('Đóng'),
                              ),
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
                                    Users teacher =
                                        teacherController.listTeachers.value
                                            .firstWhereOrNull(
                                              (t) => t.id == item.id,
                                            ) ??
                                        Users.initUser();
                                    teacher.active = false;
                                    teacher.reason_lock =
                                        reasonLockController.text;
                                    Get.back();
                                    await teacherController.updateStatusTeacher(
                                      teacher,
                                    );
                                  }
                                },
                                child: Text('Xác nhận'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    color: AppColor.lightBlue,
                    itemBuilder: (context) => [
                      item.active
                          ? PopupMenuItem(
                              value: 'lock',
                              child: ListTile(
                                leading: Icon(Icons.circle, color: Colors.grey),
                                textColor: Colors.grey,
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                title: Text('Khóa'),
                              ),
                            )
                          : PopupMenuItem(
                              value: 'active',
                              child: ListTile(
                                leading: Icon(
                                  Icons.circle,
                                  color: AppColor.blue,
                                ),
                                textColor: AppColor.blue,
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                title: Text('Kích hoạt'),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(Get.height * 0.01),
              child: Text(
                item.fullname.toUpperCase(),
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
                    ' ${item.username}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(Get.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone),
                  Text(
                    ' ${item.phone ?? ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(Get.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email),
                  Text(
                    ' ${item.email ?? ''}',
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
      // height: 100 + Random().nextInt(100).toDouble(),
    );
  }
}
