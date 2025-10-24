// lib/features/quizzes/models/question_model.dart

class Option {
  final int id;
  final String text;

  Option({required this.id, required this.text});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(id: json['id'], text: json['text']);
  }
}

class Question {
  final int id;
  final String text;
  final String qtype; // "MCQ" or "ORDER"
  final List<Option> options;

  Question({
    required this.id,
    required this.text,
    required this.qtype,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsFromJson = json['options'] as List? ?? [];
    List<Option> optionsList = optionsFromJson
        .map((optionJson) => Option.fromJson(optionJson))
        .toList();

    return Question(
      id: json['id'],
      text: json['text'],
      qtype: json['qtype'],
      options: optionsList,
    );
  }
}
