// lib/features/booking/models/session_model.dart

class Session {
  final int id;
  final DateTime startDt;
  final DateTime endDt;
  final String status;

  Session({
    required this.id,
    required this.startDt,
    required this.endDt,
    required this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      startDt: DateTime.parse(json['start_dt']),
      endDt: DateTime.parse(json['end_dt']),
      status: json['status'],
    );
  }
}
