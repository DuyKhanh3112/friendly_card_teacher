// ignore_for_file: invalid_use_of_protected_member

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/controllers/question_controller.dart';
import 'package:friendly_card_teacher/controllers/teacher_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/controllers/vocabulary_controller.dart';
import 'package:friendly_card_teacher/utils/tool.dart';
import 'package:get/get.dart';

class OverviewController extends GetxController {
  RxBool loading = false.obs;

  RxInt countVocabulary = 0.obs;
  RxInt countQuestion = 0.obs;

  RxList<BarChartGroupData> barGroupVocabulary = <BarChartGroupData>[].obs;
  RxList<BarChartGroupData> barGroupQuestion = <BarChartGroupData>[].obs;
  RxList<BarChartGroupData> barGroupTopic = <BarChartGroupData>[].obs;
  RxList<BarChartGroupData> barGroupTeacher = <BarChartGroupData>[].obs;

  Future<void> getStatistic() async {
    loading.value = true;
    TeacherController teacherController = Get.find<TeacherController>();
    barGroupTeacher.value = [];
    barGroupTeacher.value.addAll([
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: teacherController.listTeachers.value
                .where((t) => t.active)
                .length
                .toDouble(),
            width: Get.width * 0.1,
            color: Colors.green,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: teacherController.listTeachers.value
                .where((t) => !t.active)
                .length
                .toDouble(),
            width: Get.width * 0.1,
            color: Colors.grey,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
    ]);

    barGroupTopic.value = [];
    barGroupTopic.value.addAll(
      Tool.listStatus.map(
        (status) => BarChartGroupData(
          x: Tool.listStatus
              .map((s) => s['value'])
              .toList()
              .indexOf(status['value']),
          barRods: [
            BarChartRodData(
              toY: Get.find<TopicController>().listTopics.value
                  .where((t) => t.status == status['value'])
                  .length
                  .toDouble(),
              width: Get.width * 0.1,
              color: status['color'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );

    countVocabulary.value = 0;
    barGroupVocabulary.value = [];

    // Collect counts for each status asynchronously
    List<int> countVoca = await Future.wait(
      Tool.listStatus.map(
        (status) => Get.find<VocabularyController>().countVocabularyByStatus(
          status['value'],
        ),
      ),
    );

    // Build BarChartGroupData synchronously using the collected counts
    barGroupVocabulary.value.addAll(
      List.generate(Tool.listStatus.length, (index) {
        final status = Tool.listStatus[index];
        final count = countVoca[index];
        countVocabulary.value += count;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              width: Get.width * 0.1,
              color: status['color'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }),
    );

    countQuestion.value = 0;
    barGroupQuestion.value = [];
    List<int> countQuest = await Future.wait(
      Tool.listStatus.map(
        (status) =>
            Get.find<QuestionController>().countQuestionStatus(status['value']),
      ),
    );
    barGroupQuestion.value.addAll(
      List.generate(Tool.listStatus.length, (index) {
        final status = Tool.listStatus[index];
        final count = countQuest[index];
        countQuestion.value += count;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              width: Get.width * 0.1,
              color: status['color'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }),
    );

    loading.value = false;
  }
}
