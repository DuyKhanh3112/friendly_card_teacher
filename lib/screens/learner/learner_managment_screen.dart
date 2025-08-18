// ignore_for_file: prefer_const_constructors, sort_child_properties_last, invalid_use_of_protected_member, sized_box_for_whitespace, deprecated_member_use, unrelated_type_equality_checks, avoid_unnecessary_containers

import 'package:convert_vietnamese/convert_vietnamese.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/components/custom_search_field.dart';
import 'package:friendly_card_teacher/controllers/learner_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/widget/empty_data.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:friendly_card_teacher/models/users.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

class LearnerManagmentScreen extends StatelessWidget {
  const LearnerManagmentScreen({super.key});

  void loadData(
    RxList<Users> listLearner,
    RxInt currentPage,
    Rx<TextEditingController> searchController,
  ) {
    LearnerController learnerController = Get.find<LearnerController>();

    listLearner.value = learnerController.listLearner
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

    listLearner.sort((a, b) => b.update_at.compareTo(a.update_at));
  }

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();
    LearnerController learnerController = Get.find<LearnerController>();

    Rx<TextEditingController> searchController = TextEditingController().obs;
    RxList<Users> listLearner = <Users>[].obs;
    RxInt currentPage = 0.obs;
    RxInt offset = 0.obs;
    RxInt limit = 6.obs;
    return Obx(() {
      // listLearner.value = listLearner.value
      //     .where((t) => t.active == (currentPage == 0))
      //     .toList();
      loadData(listLearner, currentPage, searchController);
      return usersController.loading.value || learnerController.loading.value
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
                                listLearner,
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
                              learnerController.loading.value = true;
                              searchController.value.clear();
                              await learnerController.loadLearner();
                              loadData(
                                listLearner,
                                currentPage,
                                searchController,
                              );
                              learnerController.loading.value = false;
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
                      ],
                    ),
                  ),
                  Divider(),
                  learnerController.listLearner.isEmpty
                      ? EmptyData()
                      : Expanded(
                          child: FlexibleGridView(
                            axisCount: GridLayoutEnum.threeElementsInRow,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children: listLearner.value
                                // .where((t) => t.active == (currentPage == 0))
                                .toList()
                                .getRange(
                                  offset.value * limit.value,
                                  (offset.value + 1) * limit.value >=
                                          listLearner.value
                                              .where(
                                                (t) =>
                                                    t.active ==
                                                    (currentPage == 0),
                                              )
                                              .length
                                      ? listLearner.value
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

              // bottomNavigationBar: BottomNavigationBar(
              //   elevation: 15,
              //   type: BottomNavigationBarType.fixed,
              //   selectedFontSize: 16,
              //   unselectedFontSize: 13,
              //   selectedIconTheme: const IconThemeData(size: 32),
              //   unselectedIconTheme: const IconThemeData(size: 24),
              //   showUnselectedLabels: true,
              //   backgroundColor: AppColor.blue,
              //   unselectedItemColor: AppColor.labelBlue,
              //   unselectedLabelStyle: TextStyle(color: AppColor.labelBlue),
              //   selectedLabelStyle: TextStyle(
              //     fontWeight: FontWeight.w500,
              //     color: Colors.white,
              //   ),
              //   selectedItemColor: Colors.white,
              //   items: [
              //     BottomNavigationBarItem(
              //       icon: Icon(Icons.check_circle),
              //       label:
              //           'Đang hoạt động (${listLearner.where((t) => t.active).length})',
              //     ),
              //     BottomNavigationBarItem(
              //       icon: Icon(Icons.cancel),
              //       label:
              //           'Đã bị khóa (${listLearner.where((t) => !t.active).length})',
              //     ),
              //   ],
              //   currentIndex: currentPage.value,
              //   onTap: (value) {
              //     offset.value = 0;
              //     currentPage.value = value;
              //   },
              // ),
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
                            listLearner.value
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
          // teacherController.teacher.value = item;
          // await teacherController.loadTeacherInfo(item.id);
          // Get.toNamed('/teacher_form');
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
