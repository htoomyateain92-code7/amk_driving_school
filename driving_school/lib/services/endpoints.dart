// lib/services/endpoints.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api.dart';

class Endpoints {
  // 🔐 Secure storage instance
  static const _storage = FlutterSecureStorage();

  // === AUTH (accounts) ===
  static Future<Map> login(String u, String p) async {
    final r = await api.post(
      '/accounts/auth/login/',
      data: {'username': u, 'password': p},
    );
    return Map<String, dynamic>.from(r.data);
  }

  static Future<Map> me() async {
    final r = await api.get('/accounts/auth/me/');
    return Map<String, dynamic>.from(r.data);
  }

  static Future<void> register({
    required String username,
    String? email,
    required String password,
  }) async {
    await api.post(
      '/accounts/auth/register/',
      data: {
        'username': username,
        if (email?.isNotEmpty == true) 'email': email,
        'password': password,
      },
    );
  }

  static Future<void> changePassword(String oldPwd, String newPwd) async {
    await api.post(
      '/accounts/auth/change-password/',
      data: {'old_password': oldPwd, 'new_password': newPwd},
    );
  }

  // === COURSES ===
  static Future<List> listCourses({bool publicOnly = false}) async {
    final r = await api.get(
      '/core/api/courses/',
      q: publicOnly ? {'public': 'true'} : null,
    );
    return List.from(r.data);
  }

  // === BATCHES ===
  static Future<List> listBatches() async {
    final r = await api.get('/core/api/batches/');
    return List.from(r.data);
  }

  static Future<List> availableBatchesForMe() async {
    final r = await api.get('/core/api/batches/available_for_me/');
    return List.from(r.data);
  }

  // === ENROLLMENTS ===
  static Future<Map> enroll({required int userId, required int batchId}) async {
    final r = await api.post(
      '/core/api/enrollments/',
      data: {'user': userId, 'batch': batchId},
    );
    return Map<String, dynamic>.from(r.data);
  }

  // === SESSIONS ===
  static Future<List> listSessions() async {
    final r = await api.get('/core/api/sessions/');
    return List.from(r.data);
  }

  static Future<List> todayForTeacher() async {
    final r = await api.get('/core/api/sessions/today_for_teacher/');
    return List.from(r.data);
  }

  static Future<Map> generateSessions({
    required int batchId,
    required List<int> weekdays,
    required String startTime, // "16:00"
    required int durationMin, // 60 or 90
    required String since, // "YYYY-MM-DD"
    required String until, // "YYYY-MM-DD"
  }) async {
    final r = await api.post(
      '/core/api/sessions/generate/',
      data: {
        'batch_id': batchId,
        'weekdays': weekdays,
        'start_time': startTime,
        'duration_min': durationMin,
        'since': since,
        'until': until,
      },
    );
    return Map<String, dynamic>.from(r.data);
  }

  static Future<void> markCompleted(int sessionId) async {
    await api.post('/core/api/sessions/$sessionId/mark_completed/', data: {});
  }

  // === PUSH (FCM) ===
  static Future<void> registerDevice(String token, String platform) async {
    await api.post(
      '/core/api/push/register-device/',
      data: {'token': token, 'platform': platform},
    );
  }

  // === Token Storage Helpers ===
  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'access');
    await _storage.delete(key: 'refresh');
  }

  static Future<String?> get access async => _storage.read(key: 'access');
  static Future<String?> get refresh async => _storage.read(key: 'refresh');
}
