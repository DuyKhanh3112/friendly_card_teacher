// ignore_for_file: prefer_const_constructors, sort_child_properties_last, invalid_use_of_protected_member, sized_box_for_whitespace, deprecated_member_use, unrelated_type_equality_checks, avoid_unnecessary_containers, avoid_function_literals_in_foreach_calls

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/controllers/learner_controller.dart';
import 'package:friendly_card_teacher/controllers/main_controller.dart';
import 'package:friendly_card_teacher/controllers/overview_controller.dart';
import 'package:friendly_card_teacher/controllers/teacher_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/utils/tool.dart';
import 'package:friendly_card_teacher/widget/loading_page.dart';
import 'package:friendly_card_teacher/utils/app_color.dart';
import 'package:get/get.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.find<UsersController>();
    OverviewController overviewController = Get.find<OverviewController>();
    return Obx(() {
      return usersController.loading.value || overviewController.loading.value
          ? const LoadingPage()
          : Scaffold(
              body: ListView(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
                children: [
                  Container(
                    margin: EdgeInsets.only(top: Get.height * 0.025),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: Get.width * 0.05,
                          child: IconButton(
                            onPressed: () async {
                              overviewController.loading.value = true;

                              if (usersController.user.value.role == 'admin') {
                                await Get.find<MainController>()
                                    .loadAllDataForAdmin();
                              } else {
                                await Get.find<TopicController>()
                                    .loadTopicTeacher();
                              }
                              await overviewController.getStatistic();
                              overviewController.loading.value = false;
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
                  _buildSummaryGrid(),

                  overviewController.barGroupTeacher.value.isEmpty ||
                          usersController.user.value.role != 'admin'
                      ? SizedBox()
                      : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: Get.height * 0.05),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                    'Số giáo viên theo trạng thái',
                                  ),
                                  Container(
                                    // height: Get.height * 0.4,
                                    // padding: const EdgeInsets.only(top: 16),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(24),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: _buildBarChart(
                                      overviewController.barGroupTeacher.value,
                                      'Giáo viên',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                  Get.find<TopicController>().listTopics.value.isEmpty
                      ? SizedBox()
                      : Container(
                          margin: EdgeInsets.only(top: Get.height * 0.05),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Số chủ đề theo trạng thái'),
                              Container(
                                // height: Get.height * 0.4,
                                // padding: const EdgeInsets.only(top: 16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(24),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _buildBarChart(
                                  overviewController.barGroupTopic.value,
                                  'Giáo viên',
                                ),
                              ),
                            ],
                          ),
                        ),

                  overviewController.countVocabulary.value == 0
                      ? SizedBox()
                      : Container(
                          margin: EdgeInsets.only(top: Get.height * 0.05),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Số từ vựng theo trạng thái'),
                              Container(
                                // height: Get.height * 0.6,
                                // padding: const EdgeInsets.only(top: 16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(24),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _buildBarChart(
                                  overviewController.barGroupVocabulary.value,
                                  'Từ vựng',
                                ),
                              ),
                            ],
                          ),
                        ),

                  overviewController.countQuestion.value == 0
                      ? SizedBox()
                      : Container(
                          margin: EdgeInsets.only(top: Get.height * 0.05),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Số câu hỏi theo trạng thái'),
                              Container(
                                // height: Get.height * 0.6,
                                // padding: const EdgeInsets.only(top: 16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(24),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _buildBarChart(
                                  overviewController.barGroupQuestion.value,
                                  'Câu hỏi',
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
              backgroundColor: AppColor.lightBlue,
            );
    });
  }

  Widget _buildSummaryGrid() {
    // OverviewController overviewController = Get.find<OverviewController>();
    UsersController usersController = Get.find<UsersController>();
    return Container(
      margin: EdgeInsets.only(top: Get.height * 0.05),
      child: GridView.count(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.8,
        children: usersController.user.value.role == 'admin'
            ? [
                _SummaryCard(
                  title: 'Giáo viên',
                  value: Get.find<TeacherController>().listTeachers.value.length
                      .toString(),
                  icon: Icons.supervised_user_circle,
                  color: Colors.orange,
                ),
                _SummaryCard(
                  title: 'Người học',
                  value: Get.find<LearnerController>().listLearner.value.length
                      .toString(),
                  icon: Icons.person,
                  color: Colors.red,
                ),
                _SummaryCard(
                  title: 'Chủ đề được thêm',
                  value: Get.find<TopicController>().listTopics.value.length
                      .toString(),
                  icon: Icons.topic_rounded,
                  color: Colors.green,
                ),
                _SummaryCard(
                  title: 'Từ vựng được thêm',
                  value: Get.find<OverviewController>().countVocabulary.value
                      .toString(),
                  icon: Icons.style_rounded,
                  color: Colors.blue,
                ),
                _SummaryCard(
                  title: 'Câu hỏi được thêm',
                  value: Get.find<OverviewController>().countQuestion.value
                      .toString(),
                  icon: Icons.question_answer,
                  color: Colors.purple,
                ),
              ]
            : [
                SizedBox(),
                _SummaryCard(
                  title: 'Chủ đề được thêm',
                  value: Get.find<TopicController>().listTopics.value.length
                      .toString(),
                  icon: Icons.topic_rounded,
                  color: Colors.green,
                ),

                _SummaryCard(
                  title: 'Từ vựng được thêm',
                  value: Get.find<OverviewController>().countVocabulary.value
                      .toString(),
                  icon: Icons.style_rounded,
                  color: Colors.blue,
                ),
                _SummaryCard(
                  title: 'Câu hỏi được thêm',
                  value: Get.find<OverviewController>().countQuestion.value
                      .toString(),
                  icon: Icons.question_answer,
                  color: Colors.purple,
                ),

                SizedBox(),
              ],
      ),
    );
    // });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        // color: AppColor.drakBlue,
      ),
    );
  }

  Widget _buildBarChart(List<BarChartGroupData> barGroups, String unit) {
    double maxY = 0;
    double interval = 2;
    barGroups.forEach((item) {
      for (var bar in item.barRods) {
        maxY = max(maxY, bar.toY);
      }
    });

    // maxY = maxY % (interval) == 0 ? (maxY + 2) : (maxY + 3);
    if (maxY > 30) {
      interval = 5;
    }
    maxY = maxY % (interval) == 0
        ? maxY + interval
        : (maxY + 2 * interval - maxY % interval);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: barGroups.length * Get.width * 0.2 > Get.width
            ? barGroups.length * Get.width * 0.2
            : Get.width,
        height: maxY * Get.height * 0.015 > 400
            ? maxY * Get.height * 0.015
            : 400,
        padding: EdgeInsets.only(
          top: Get.height * 0.03,
          left: Get.width * 0.0125,
          right: Get.width * 0.125,
          bottom: Get.height * 0.05,
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,

            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                // tooltipBgColor: Colors.blueGrey,
                tooltipPadding: EdgeInsets.all(5),
                maxContentWidth: Get.width * 0.4,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  var title = Tool.listStatus[group.x]['label'];
                  if (barGroups.length == 2) {
                    title = group.x == 0 ? 'Đang hoạt động' : "Đã bị khóa";
                  }
                  return BarTooltipItem(
                    '${rod.toY.toInt()} ${unit.toLowerCase()} ${title.toString().toLowerCase()}',
                    TextStyle(
                      color: AppColor.labelBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    var title = Tool.listStatus[value.toInt()]['label'];
                    if (barGroups.length == 2) {
                      title = value.toInt() == 0
                          ? 'Đang hoạt động'
                          : "Đã bị khóa";
                    }
                    return Container(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: interval,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.shade300, strokeWidth: 1),
            ),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.015,
          vertical: Get.height * 0.01,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Icon(icon, color: color, size: 48),
              ],
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black54,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
