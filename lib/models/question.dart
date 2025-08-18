// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String id;
  String question_type_id;
  String content;
  String mean;
  String topic_id;
  String status;
  Timestamp update_at;

  Question({
    required this.id,
    required this.question_type_id,
    required this.content,
    required this.mean,
    required this.topic_id,
    required this.update_at,
    required this.status,
  });

  factory Question.initQuestion() {
    return Question(
      id: '',
      question_type_id: '',
      content: '',
      mean: '',
      topic_id: '',
      update_at: Timestamp.now(),
      status: 'await',
    );
  }

  static Question fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question_type_id: json['question_type_id'],
      content: json['content'],
      mean: json['mean'],
      topic_id: json['topic_id'],
      update_at: json['update_at'],
      status: json['status'] ?? 'await',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_type_id': question_type_id,
      'content': content,
      'mean': mean,
      'topic_id': topic_id,
      'update_at': update_at,
      'status': status,
    };
  }

  Map<String, dynamic> toVal() {
    return {
      // 'id': id,
      'question_type_id': question_type_id,
      'content': content,
      'mean': mean,
      'topic_id': topic_id,
      'update_at': update_at,
      'status': status,
    };
  }
}
