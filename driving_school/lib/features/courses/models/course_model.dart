class Instructor {
  final int id;
  final String username;
  // Add other fields like email if your API returns them

  Instructor({required this.id, required this.username});

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'],
      username: json['username'],
    );
  }
}

class Batch {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final Instructor instructor;

  Batch({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.instructor,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      title: json['title'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      instructor: Instructor.fromJson(json['instructor']),
    );
  }
}

class Course {
  final int id;
  final String title;
  final String code;
  final String description;
  final double totalDurationHours;
  final List<Batch>? batches; // Can be null if not in detail view

  Course({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.totalDurationHours,
    this.batches,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      code: json['code'],
      description: json['description'],
      totalDurationHours:
          double.tryParse(json['total_duration_hours'].toString()) ?? 0.0,
      batches: json['batches'] != null
          ? (json['batches'] as List).map((i) => Batch.fromJson(i)).toList()
          : null,
    );
  }
}
