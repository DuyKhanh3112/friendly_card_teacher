import 'package:friendly_card_teacher/controllers/learner_controller.dart';
import 'package:friendly_card_teacher/controllers/main_controller.dart';
import 'package:friendly_card_teacher/controllers/overview_controller.dart';
import 'package:friendly_card_teacher/controllers/question_controller.dart';
import 'package:friendly_card_teacher/controllers/teacher_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/controllers/vocabulary_controller.dart';
import 'package:get/get.dart';

class InitalBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(MainController());
    Get.put(UsersController());
    Get.put(TeacherController());
    Get.put(TopicController());
    Get.put(VocabularyController());
    Get.put(LearnerController());
    Get.put(QuestionController());
    Get.put(OverviewController());

    await Get.find<QuestionController>().loadQuestionType();
    // Get.find<UsersController>().checkLogin();
  }
}

// class AdminBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.find<UsersController>().checkLogin();
//   }
// }
