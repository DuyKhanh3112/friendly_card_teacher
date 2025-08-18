// ignore_for_file: non_constant_identifier_names

class TeacherInfo {
  String id;
  String user_id;
  String attachments;
  String name;

  TeacherInfo({
    required this.id,
    required this.user_id,
    required this.attachments,
    required this.name,
  });

  factory TeacherInfo.initTeacherInfo() {
    return TeacherInfo(id: '', user_id: '', attachments: '', name: '');
  }

  static TeacherInfo fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      id: json['id'],
      user_id: json['user_id'],
      attachments: json['attachments'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'attachments': attachments,
      'name': name,
    };
  }

  Map<String, dynamic> toVal() {
    return {
      // 'id': id,
      'user_id': user_id,
      'attachments': attachments,
      'name': name,
    };
  }
}
