// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String id;
  String username;
  String password;
  String fullname;
  String? email;
  String? phone;
  Timestamp update_at;
  String role;
  String? avatar;
  bool active;
  String? reason_lock;

  Users({
    required this.id,
    required this.username,
    required this.password,
    required this.fullname,
    this.email,
    this.phone,
    this.avatar,
    required this.update_at,
    required this.role,
    required this.active,
    this.reason_lock,
  });

  factory Users.initUser() {
    return Users(
      id: '',
      username: '',
      password: '',
      fullname: '',
      update_at: Timestamp.now(),
      role: '',
      email: '',
      phone: '',
      avatar: '',
      active: true,
      reason_lock: '',
    );
  }
  factory Users.initLearner() {
    return Users(
      id: '',
      username: '',
      password: '',
      fullname: '',
      update_at: Timestamp.now(),
      role: 'learner',
      email: '',
      phone: '',
      avatar: '',
      active: true,
      reason_lock: '',
    );
  }
  factory Users.initTeacher() {
    return Users(
      id: '',
      username: '',
      password: '',
      fullname: '',
      update_at: Timestamp.now(),
      role: 'teacher',
      email: '',
      phone: '',
      avatar: '',
      active: true,
      reason_lock: '',
    );
  }

  static Users fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      fullname: json['fullname'],
      update_at: json['update_at'],
      role: json['role'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      active: json['active'],
      reason_lock: json['reason_lock'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullname': fullname,
      'update_at': update_at,
      'role': role,
      'email': email ?? '',
      'phone': phone ?? '',
      'avatar': avatar ?? '',
      'active': active,
      'reason_lock': reason_lock
    };
  }

  Map<String, dynamic> toVal() {
    return {
      // 'id': id,
      'username': username,
      'password': password,
      'fullname': fullname,
      'update_at': update_at,
      'role': role,
      'email': email ?? '',
      'phone': phone ?? '',
      'avatar': avatar ?? '',
      'active': active,
      'reason_lock': reason_lock,
    };
  }
}
