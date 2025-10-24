class Course {
  final int id;
  final String title;
  final String code;
  final String description;
  final double totalDurationHours;
  final List<Batch> batches;

  Course({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.totalDurationHours,
    required this.batches,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Safely parse batches
    var batchList = <Batch>[];
    if (json['batches'] != null && json['batches'] is List) {
      batchList = (json['batches'] as List)
          .map((batchJson) => Batch.fromJson(batchJson))
          .toList();
    }

    return Course(
      // Use int.parse to handle both "1" and 1
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      // Safely parse the duration, defaulting to 0.0 if null or invalid
      totalDurationHours:
          double.tryParse(json['total_duration_hours'].toString()) ?? 0.0,
      batches: batchList,
    );
  }
}

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
      // Use int.parse to handle both "1" and 1
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      // Assuming instructor is a nested object in your JSON
      instructorName: json['instructor']?['username'] ?? 'N/A',
    );
  }
}
