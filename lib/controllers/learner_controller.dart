// ignore_for_file: invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_card_teacher/models/users.dart';
import 'package:get/get.dart';

class LearnerController extends GetxController {
  RxBool loading = false.obs;
  CollectionReference usersCollection = FirebaseFirestore.instance.collection(
    'users',
  );

  RxList<Users> listLearner = <Users>[].obs;
  Rx<Users> learner = Users.initLearner().obs;

  Future<void> loadLearner() async {
    loading.value = true;
    listLearner.value = [];
    final snapshoot = await usersCollection
        .where('role', isEqualTo: 'learner')
        .get();

    for (var doc in snapshoot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      listLearner.value.add(Users.fromJson(data));
    }
    loading.value = false;
  }
}
