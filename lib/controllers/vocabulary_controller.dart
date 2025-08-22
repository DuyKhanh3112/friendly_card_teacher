// ignore_for_file: invalid_use_of_protected_member, depend_on_referenced_packages, prefer_adjacent_string_concatenation, avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_card_teacher/config.dart';
import 'package:friendly_card_teacher/controllers/cloudinary_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/models/vocabulary.dart';
import 'package:friendly_card_teacher/utils/tool.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VocabularyController extends GetxController {
  RxBool loading = false.obs;

  CollectionReference vocabularyCollection = FirebaseFirestore.instance
      .collection('vocabulary');

  RxList<Vocabulary> listVocabulary = <Vocabulary>[].obs;
  Rx<Vocabulary> vocabulary = Vocabulary.initVocabulary().obs;

  Future<void> loadVocabularyTopic() async {
    loading.value = true;
    listVocabulary.value = [];
    TopicController topicController = Get.find<TopicController>();
    var snapshoot = await vocabularyCollection
        .where('topic_id', isEqualTo: topicController.topic.value.id)
        .get();
    for (var item in snapshoot.docs) {
      Map<String, dynamic> data = item.data() as Map<String, dynamic>;
      data['id'] = item.id;
      listVocabulary.add(Vocabulary.fromJson(data));
    }
    loading.value = false;
  }

  Future<int> countVocabularyByStatus(String status, String topicID) async {
    var snapshoot = await vocabularyCollection
        .where('status', isEqualTo: status)
        .where('topic_id', isEqualTo: topicID)
        .get();
    return snapshoot.docs.length;
  }

  Future<void> createVocabulary(Vocabulary item, String imgBase64) async {
    loading.value = true;
    WriteBatch batch = FirebaseFirestore.instance.batch();

    String id = vocabularyCollection.doc().id;
    if (imgBase64 != '') {
      String imgUrl = await CloudinaryController().uploadImageFile(
        imgBase64,
        id,
        'topic/${item.topic_id}/vocabulary',
      );
      item.image = imgUrl;
    }
    DocumentReference vocaRef = vocabularyCollection.doc(id);
    item.update_at = Timestamp.now();
    batch.set(vocaRef, item.toVal());

    await batch.commit();
    // await loadVocabularyTopic();
    loading.value = false;
  }

  Future<void> generateVocabulary(int num) async {
    loading.value = true;
    TopicController topicController = Get.find<TopicController>();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    );

    final headers = {
      'Content-Type': 'application/json',
      'X-goog-api-key': Config.API_KEY,
    };
    String names = '';
    for (var element in listVocabulary.value) {
      names += '${element.name},';
    }
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Hãy cho tôi $num từ vựng tiếng Anh, " +
                  "với chủ đề ${topicController.topic.value.name == '' ? 'Động vật' : topicController.topic.value.name}," +
                  " trả về gồm: từ vựng tiếng Anh, nghĩa tiếng Việt, ví dụ, nghĩa tiếng Việt của ví dụ và phiên âm. " +
                  "Dạng mảng bao gồm: vocabulary, mean, example, mean_example, transcription. ${names != '' ? "Khác các từ : $names" : ''}",
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
        final vocabList = Tool.parseList(data);

        vocabList.forEach((item) async {
          item['id'] = '';
          item['name'] = item['vocabulary'];
          item['topic_id'] = topicController.topic.value.id;
          item['active'] = false;
          item['update_at'] = Timestamp.now();
          item['image'] =
              'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png';

          await createVocabulary(Vocabulary.fromJson(item), '');
        });
      }
      await loadVocabularyTopic();
      loading.value = false;
    } catch (e) {
      loading.value = false;
    }
  }

  Future<void> updateStatusVocabulary(Vocabulary item, String status) async {
    loading.value = true;
    item.update_at = Timestamp.now();
    item.status = status;
    await vocabularyCollection.doc(item.id).update(item.toVal());
    await loadVocabularyTopic();
    loading.value = false;
  }

  Future<void> updateVocabulary(String imgBase64) async {
    loading.value = true;
    if (imgBase64 != '') {
      String imgUrl = await CloudinaryController().uploadImageFile(
        imgBase64,
        vocabulary.value.id,
        'topic/${vocabulary.value.topic_id}/vocabulary',
      );
      vocabulary.value.image = imgUrl;
    }
    vocabulary.value.update_at = Timestamp.now();
    await vocabularyCollection
        .doc(vocabulary.value.id)
        .update(vocabulary.value.toVal());
    await loadVocabularyTopic();
    loading.value = false;
  }
}
