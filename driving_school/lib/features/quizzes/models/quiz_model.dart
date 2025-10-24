class Quiz {
  final int id;
  final String title;
  final int questionCount;

  Quiz({required this.id, required this.title, required this.questionCount});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
        id: json['id'],
        title: json['title'],
        questionCount: json['questions']?.length ?? 0);
  }
}
