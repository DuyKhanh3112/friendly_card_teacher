// ignore_for_file: non_constant_identifier_names

class QuestionType {
  String id;
  String name;
  int num_option;

  QuestionType({
    required this.id,
    required this.name,
    required this.num_option,
  });

  factory QuestionType.initQuestionType() {
    return QuestionType(
      id: '',
      name: '',
      num_option: 0,
    );
  }

  static QuestionType fromJson(Map<String, dynamic> json) {
    return QuestionType(
      id: json['id'],
      name: json['name'],
      num_option: json['num_option'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'num_option': num_option,
    };
  }

  Map<String, dynamic> toVal() {
    return {
      // 'id': id,
      'name': name,
      'num_option': num_option,
    };
  }
}
