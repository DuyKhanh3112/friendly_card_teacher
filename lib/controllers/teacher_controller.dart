// ignore_for_file: invalid_use_of_protected_member, non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_card_teacher/controllers/cloudinary_controller.dart';
import 'package:friendly_card_teacher/controllers/main_controller.dart';
import 'package:friendly_card_teacher/models/teacher_info.dart';
import 'package:friendly_card_teacher/models/users.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class TeacherController extends GetxController {
  RxBool loading = false.obs;
  CollectionReference usersCollection = FirebaseFirestore.instance.collection(
    'users',
  );
  CollectionReference teacherInfoCollection = FirebaseFirestore.instance
      .collection('teacher_info');
  RxList<Users> listTeachers = <Users>[].obs;
  Rx<Users> teacher = Users.initTeacher().obs;
  RxList<TeacherInfo> listTeacherInfo = <TeacherInfo>[].obs;

  Future<void> loadAllData() async {
    loading.value = true;
    listTeachers.value = [];
    final snapshoot = await usersCollection
        .where('role', isEqualTo: 'teacher')
        .get();

    for (var doc in snapshoot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      await loadTeacherInfo(doc.id);
      listTeachers.value.add(Users.fromJson(data));
    }

    loading.value = false;
  }

  Future<void> loadTeacherInfo(String teacherId) async {
    // loading.value = true;
    listTeacherInfo.value = [];
    var snapshoot = await teacherInfoCollection
        .where('user_id', isEqualTo: teacherId)
        .get();
    for (var doc in snapshoot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      listTeacherInfo.add(TeacherInfo.fromJson(data));
    }
    // loading.value = false;
  }

  Future<void> updateTeacher(
    Users teach,
    List<XFile> listFile,
    List<TeacherInfo> listInfo,
  ) async {
    loading.value = true;
    teach.update_at = Timestamp.now();
    teach.role = 'teacher';
    await usersCollection.doc(teach.id).update(teach.toVal());

    listTeacherInfo.value
        .where((item) => listInfo.where((i) => i.id == item.id).isEmpty)
        .forEach((item) async {
          await deleteTeacherInfo(item);
        });
    // listTeacherInfo.value = listInfo;

    await createTeacherInfor(listFile, teach.id);
    await loadAllData();
    await loadTeacherInfo(teach.id);
    loading.value = false;
  }

  Future<void> updateStatusTeacher(Users teach) async {
    loading.value = true;
    teach.update_at = Timestamp.now();
    teach.role = 'teacher';
    await usersCollection.doc(teach.id).update(teach.toVal());
    await loadAllData();
    // teacher.value = Users.initTeacher();
    loading.value = false;
  }

  Future<void> createTeacher(List<XFile> listFile) async {
    loading.value = true;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    String id = usersCollection.doc().id;
    DocumentReference refTeacher = usersCollection.doc(id);
    teacher.value.update_at = Timestamp.now();
    teacher.value.role = 'teacher';
    teacher.value.password = teacher.value.username;
    teacher.value.avatar =
        'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png';
    batch.set(refTeacher, teacher.value.toVal());
    await batch.commit();
    createTeacherInfor(listFile, id);
    await loadAllData();
    unawaited(Get.find<MainController>().sendMailWelcome(teacher.value));
    teacher.value = Users.initTeacher();
    loading.value = false;
  }

  Future<void> createTeacherInfor(List<XFile> listFile, String user_id) async {
    loading.value = true;
    listTeacherInfo.value = [];
    for (var file in listFile) {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      String id = usersCollection.doc().id;
      DocumentReference refTeacherInfo = teacherInfoCollection.doc(id);
      TeacherInfo info = TeacherInfo.initTeacherInfo();
      info.user_id = user_id;
      info.name = file.name;
      info.attachments = await CloudinaryController().uploadImageFile(
        file.path,
        id,
        'teacher/${user_id}/attachments',
      );
      batch.set(refTeacherInfo, info.toVal());
      await batch.commit();
      listTeacherInfo.value.add(info);
    }
    await loadTeacherInfo(user_id);
    loading.value = false;
  }

  Future<void> deleteTeacherInfo(TeacherInfo info) async {
    await teacherInfoCollection.doc(info.id).delete();
    await CloudinaryController().deleteImage(
      'teacher/${info.user_id}/attachments/${info.id}',
    );
  }
}
