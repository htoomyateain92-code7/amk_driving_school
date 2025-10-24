class Batch {
  final int id;
  final String title;
  final String instructorName;

  Batch({
    required this.id,
    required this.title,
    required this.instructorName,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      // Django BatchSerializer ကနေ instructor object ပါလာမယ်
      instructorName: json['instructor']?['username'] ?? 'N/A',
    );
  }
}
