// ignore_for_file: invalid_use_of_protected_member, depend_on_referenced_packages, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, prefer_adjacent_string_concatenation

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_card_teacher/config.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/controllers/users_controller.dart';
import 'package:friendly_card_teacher/controllers/vocabulary_controller.dart';
import 'package:friendly_card_teacher/models/option.dart';
import 'package:friendly_card_teacher/models/question.dart';
import 'package:friendly_card_teacher/models/question_type.dart';
import 'package:friendly_card_teacher/utils/tool.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class QuestionController extends GetxController {
  RxBool loading = false.obs;
  CollectionReference questionTypeCollection = FirebaseFirestore.instance
      .collection('question_type');
  CollectionReference questionCollection = FirebaseFirestore.instance
      .collection('question');
  CollectionReference optionCollection = FirebaseFirestore.instance.collection(
    'option',
  );

  RxList<QuestionType> listQuestionType = <QuestionType>[].obs;
  RxList<Question> listQuestion = <Question>[].obs;
  RxList<Option> listOption = <Option>[].obs;
  Rx<Question> question = Question.initQuestion().obs;

  Future<void> loadQuestionData() async {
    loading.value = true;
    await loadQuestion();
    await loadOption();
    loading.value = false;
  }

  Future<void> loadQuestionType() async {
    listQuestionType.value = [];
    var snapshoot = await questionTypeCollection.get();
    for (var item in snapshoot.docs) {
      Map<String, dynamic> data = item.data() as Map<String, dynamic>;
      data['id'] = item.id;
      listQuestionType.value.add(QuestionType.fromJson(data));
    }
  }

  Future<void> loadQuestion() async {
    loading.value = true;
    listQuestion.value = [];
    TopicController topicController = Get.find<TopicController>();
    var snapshoot = await questionCollection
        .where('topic_id', isEqualTo: topicController.topic.value.id)
        .get();
    for (var item in snapshoot.docs) {
      Map<String, dynamic> data = item.data() as Map<String, dynamic>;
      data['id'] = item.id;
      listQuestion.value.add(Question.fromJson(data));
    }

    loading.value = false;
  }

  Future<int> countQuestionStatus(String status) async {
    if (Get.find<UsersController>().user.value.role == 'admin') {
      var snapshoot = await questionCollection
          .where('status', isEqualTo: status)
          .get();
      return snapshoot.docs.length;
    } else {
      if (Get.find<TopicController>().listTopics.isEmpty) {
        return 0;
      }
      var snapshoot = await questionCollection
          .where('status', isEqualTo: status)
          .where(
            'topic_id',
            whereIn: Get.find<TopicController>().listTopics.value.map(
              (t) => t.id,
            ),
          )
          .get();
      return snapshoot.docs.length;
    }
  }

  Future<void> loadOption() async {
    loading.value = true;
    listOption.value = [];
    for (var quest in listQuestion.value) {
      var snapshoot = await optionCollection
          .where('question_id', isEqualTo: quest.id)
          .get();
      for (var item in snapshoot.docs) {
        Map<String, dynamic> data = item.data() as Map<String, dynamic>;
        data['id'] = item.id;
        listOption.value.add(Option.fromJson(data));
      }
    }
    // loading.value = false;
  }

  Future<void> createQuestionGenerate(
    Question item,
    List<dynamic> options,
    String answer,
  ) async {
    loading.value = true;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    QuestionType type =
        listQuestionType.value.firstWhereOrNull(
          (t) => t.id == item.question_type_id,
        ) ??
        QuestionType.initQuestionType();
    String id = questionCollection.doc().id;
    DocumentReference questRef = questionCollection.doc(id);
    item.update_at = Timestamp.now();
    batch.set(questRef, item.toVal());

    await batch.commit();
    if (type.num_option == 1) {
      Option data = Option(
        id: '',
        question_id: id,
        content: answer,
        is_correct: true,
        update_at: Timestamp.now(),
      );
      await createOption(data);
    }
    if (type.num_option > 1) {
      for (var opt in options) {
        Option data = Option(
          id: '',
          question_id: id,
          content: opt?.toString().trim() ?? '',
          is_correct:
              answer.toString().trim().toLowerCase() ==
              (opt?.toString().trim().toLowerCase() ?? ''),
          update_at: Timestamp.now(),
        );
        await createOption(data);
      }
    }

    // await loadQuestionData();
    // loading.value = false;
  }

  Future<void> createQuestion(Question item, List<Option> options) async {
    loading.value = true;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    QuestionType.initQuestionType();
    String id = questionCollection.doc().id;
    DocumentReference questRef = questionCollection.doc(id);
    item.update_at = Timestamp.now();
    batch.set(questRef, item.toVal());

    await batch.commit();
    for (var opt in options) {
      opt.question_id = id;
      opt.update_at = Timestamp.now();
      await createOption(opt);
    }
  }

  Future<void> updateQuestion(Question item, List<Option> options) async {
    loading.value = true;
    item.update_at = Timestamp.now();
    await questionCollection.doc(item.id).update(item.toVal());
    for (var opt in listOption.where((opt) => opt.question_id == item.id)) {
      await deletedOption(opt);
    }
    for (var opt in options) {
      await createOption(opt);
    }
  }

  Future<void> updateStatusQuestion(Question item, String status) async {
    loading.value = true;
    item.status = status;
    item.update_at = Timestamp.now();
    await questionCollection.doc(item.id).update(item.toVal());
    await loadQuestion();
    loading.value = false;
  }

  Future<void> createOption(Option item) async {
    loading.value = true;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    String id = optionCollection.doc().id;
    DocumentReference questRef = optionCollection.doc(id);
    item.update_at = Timestamp.now();
    batch.set(questRef, item.toVal());
    await batch.commit();
    // loading.value = false;
  }

  Future<void> deletedOption(Option item) async {
    await optionCollection.doc(item.id).delete();
  }

  Future<void> deletedQuestion(Question item) async {
    loading.value = true;
    await questionCollection.doc(item.id).delete();
    for (var opt in listOption.value.where(
      (opt) => opt.question_id == item.id,
    )) {
      await deletedOption(opt);
    }
    await loadQuestion();
    loading.value = false;
  }

  Future<void> generateQuestion(int num) async {
    loading.value = true;
    TopicController topicController = Get.find<TopicController>();
    VocabularyController vocabularyController =
        Get.find<VocabularyController>();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    );

    final headers = {
      'Content-Type': 'application/json',
      'X-goog-api-key': Config.API_KEY,
    };
    String names = '';
    await vocabularyController.loadVocabularyTopic();

    for (var element in vocabularyController.listVocabulary.value) {
      names += '${element.name}, ';
    }

    String question_txt = '';
    for (var element in listQuestion.value) {
      question_txt += '${element.content}, ';
    }
    for (var type in listQuestionType.value) {
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": getText(
                  type,
                  topicController,
                  names,
                  question_txt,
                  num,
                ),
              },
            ],
          },
        ],
      });

      try {
        final response = await http.post(url, headers: headers, body: body);
        if (response.statusCode == 200) {
          final dataRes = json.decode(response.body);
          final data = dataRes['candidates'][0]['content']['parts'][0]['text']
              .toString();
          final questList = Tool.parseList(data);
          questList.forEach((item) async {
            Question quest = Question(
              id: '',
              question_type_id: type.id,
              content: item['question'],
              mean: item['mean_question'],
              topic_id: topicController.topic.value.id,
              update_at: Timestamp.now(),
              status: 'await',
            );
            await createQuestionGenerate(
              quest,
              item['options'],
              item['result'].toString(),
            );
          });
        }
        // loading.value = false;
      } catch (e) {
        loading.value = false;
      }
    }

    await loadQuestionData();
    loading.value = false;
  }

  String getText(
    QuestionType type,
    TopicController topicController,
    String names,
    String question_txt,
    int num,
  ) {
    if (type.name == 'Điền khuyết') {
      return "Hãy cho tôi $num câu hỏi bài tập tiếng Anh với dạng câu hỏi là điền khuyết," +
          " số lựa chọn là ${type.num_option}, số đáp án đúng là 1 " +
          "với chủ đề ${topicController.topic.value.name == '' ? 'Động vật' : topicController.topic.value.name}," +
          " trả về mảng json gồm: câu hỏi, nghĩa câu hỏi, các lựa chọn (dạng mảng), kết quả đúng; " +
          "Dạng mảng bao gồm: question, mean_question, options, result. Đáp án liên quan đến : $names và câu hỏi khác $question_txt";
    }
    if (type.name == 'Dịch nghĩa') {
      return "Hãy cho tôi $num câu hỏi bài tập tiếng Anh dạng dịch nghĩa 1 từ tiếng việt sang tiếng anh hoặc ngược lại," +
          " số lựa chọn là ${type.name}, số đáp án đúng là 1 " +
          "với chủ đề ${topicController.topic.value.name == '' ? 'Động vật' : topicController.topic.value.name}," +
          " trả về mảng json gồm: câu hỏi tiếng anh,  nghĩa câu hỏi, các lựa chọn (dạng mảng), kết quả đúng, " +
          "Dạng mảng bao gồm: question, mean_question, options, result. Đáp án liên quan đến : $names và câu hỏi khác $question_txt";
    }
    if (type.name == 'Sắp xếp từ') {
      return "Hãy cho tôi $num câu hỏi bài tập tiếng Anh với dạng câu hỏi là sắp xếp chữ cái," +
          "với chủ đề ${topicController.topic.value.name == '' ? 'Động vật' : topicController.topic.value.name}," +
          " trả về mảng json gồm: câu hỏi , nghĩa câu hỏi, các chữ cái gợi ý (dạng mảng, chữ cái gợi ý sắp xếp lộn lộn), kết quả đúng, nghĩa đáp án. " +
          "Dạng mảng bao gồm:  question, mean_question, options, result. Đáp án liên quan đến : $names và câu hỏi khác $question_txt";
    }
    return '';
  }
}
