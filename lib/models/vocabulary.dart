// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Vocabulary {
  String id;
  String topic_id;
  String name;
  Timestamp update_at;
  String status;
  String image;
  String mean;
  String example;
  String mean_example;
  String transcription;

  Vocabulary({
    required this.id,
    required this.topic_id,
    required this.name,
    required this.update_at,
    required this.status,
    required this.image,
    required this.example,
    required this.mean_example,
    required this.mean,
    required this.transcription,
  });

  factory Vocabulary.initVocabulary() {
    return Vocabulary(
      id: '',
      name: '',
      topic_id: '',
      update_at: Timestamp.now(),
      status: 'await',
      image: '',
      example: '',
      mean: '',
      transcription: '',
      mean_example: '',
    );
  }

  static Vocabulary fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'],
      name: json['name'],
      topic_id: json['topic_id'],
      status: json['status'] ?? 'await',
      update_at: json['update_at'],
      image: json['image'],
      example: json['example'],
      mean: json['mean'],
      transcription: json['transcription'],
      mean_example: json['mean_example'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'topic_id': topic_id,
      'status': status,
      'update_at': update_at,
      'image': image,
      'example': example,
      'mean': mean,
      'transcription': transcription,
      'mean_example': mean_example,
    };
  }

  Map<String, dynamic> toVal() {
    return {
      // 'id': id,
      'name': name,
      'topic_id': topic_id,
      'status': status,
      'update_at': update_at,
      'image': image,
      'example': example,
      'mean': mean,
      'transcription': transcription,
      'mean_example': mean_example,
    };
  }
}
