// Model for the Quiz list
class QuizInfo {
  final int id;
  final String title;
  QuizInfo({required this.id, required this.title});
  factory QuizInfo.fromJson(Map<String, dynamic> json) {
    return QuizInfo(
      id: int.parse(json['id'].toString()),
      title: json['title'],
    );
  }
}

// Model for the full Quiz details
class QuizDetail {
  final int id;
  final String title;
  final List<Question> questions;

  QuizDetail({required this.id, required this.title, required this.questions});

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List? ?? [];
    List<Question> parsedQuestions =
        questionsList.map((q) => Question.fromJson(q)).toList();
    return QuizDetail(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      questions: parsedQuestions,
    );
  }
}

class Question {
  final int id;
  final String text;
  final String qtype; // "MCQ" or "ORDER"
  final List<Option> options;

  Question(
      {required this.id,
      required this.text,
      required this.qtype,
      required this.options});

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    List<Option> parsedOptions =
        optionsList.map((o) => Option.fromJson(o)).toList();
    return Question(
      id: int.parse(json['id'].toString()),
      text: json['text'],
      qtype: json['qtype'],
      options: parsedOptions,
    );
  }
}

class Option {
  final int id;
  final String text;

  Option({required this.id, required this.text});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: int.parse(json['id'].toString()),
      text: json['text'],
    );
  }
}
