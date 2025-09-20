// lib/repositories/session_repo.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SessionDetailM {
  final int id;
  final int batch;
  final DateTime startDt;
  final DateTime endDt;
  final String status;
  final String? reason;
  final String? courseTitle;

  SessionDetailM({
    required this.id,
    required this.batch,
    required this.startDt,
    required this.endDt,
    required this.status,
    this.reason,
    this.courseTitle,
  });

  factory SessionDetailM.fromJson(Map<String, dynamic> j) => SessionDetailM(
    id: j['id'] as int,
    batch: j['batch'] as int,
    startDt: DateTime.parse(j['start_dt']),
    endDt: DateTime.parse(j['end_dt']),
    status: j['status'] as String,
    reason: j['reason'] as String?,
    courseTitle: j['course_title'] as String?,
  );
}

class SessionRepo {
  final String baseUrl;
  final Map<String, String> headers;

  SessionRepo({
    this.baseUrl = 'http://localhost:8080', // 필요에 따라 host ပြောင်းပါ
    this.headers = const {'Content-Type': 'application/json'},
  });

  Future<SessionDetailM> detail(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/core/api/sessions/$id/'),
      headers: headers,
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return SessionDetailM.fromJson(jsonDecode(res.body));
    }
    throw Exception('Session detail failed ${res.statusCode}: ${res.body}');
  }

  Future<void> markCompleted(int id, {String? reason}) async {
    final body = {'status': 'completed', if (reason != null) 'reason': reason};

    final res = await http.post(
      Uri.parse('$baseUrl/core/api/sessions/$id/mark_completed/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Mark completed failed ${res.statusCode}: ${res.body}');
    }
  }
}
