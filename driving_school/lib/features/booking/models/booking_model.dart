import '../../courses/models/course_model.dart';
import 'session_model.dart';

class Booking {
  final int id;
  final Course course;
  final List<Session> sessions;
  final String status;
  final DateTime createdAt;
  final String? instructorName;

  Booking({
    required this.id,
    required this.course,
    required this.sessions,
    required this.status,
    required this.createdAt,
    this.instructorName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      course: Course.fromJson(json['course']),
      sessions:
          (json['sessions'] as List).map((s) => Session.fromJson(s)).toList(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      instructorName: json['instructor_name'],
    );
  }
}
