// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Option {
  String id;
  String question_id;
  String content;
  bool is_correct;
  Timestamp update_at;

  Option({
    required this.id,
    required this.question_id,
    required this.content,
    required this.is_correct,
    required this.update_at,
  });

  factory Option.initOption() {
    return Option(
      id: '',
      question_id: '',
      content: '',
      is_correct: false,
      update_at: Timestamp.now(),
    );
  }

  static Option fromJson(Map<String, dynamic> json) {
    return Option(
        id: json['id'],
        question_id: json['question_id'],
        content: json['content'],
        is_correct: json['is_correct'],
        update_at: json['update_at']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': question_id,
      'content': content,
      'is_correct': is_correct,
      'update_at': update_at,
    };
  }

  Map<String, dynamic> toVal() {
    return {
      // 'id': id,
      'question_id': question_id,
      'content': content,
      'is_correct': is_correct,
      'update_at': update_at,
    };
  }
}
