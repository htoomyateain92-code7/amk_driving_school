// screens/home_after_login.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as HttpX;

class HomeAfterLogin extends StatefulWidget {
  const HomeAfterLogin({super.key});
  @override
  State<HomeAfterLogin> createState() => _HomeAfterLoginState();
}

class _HomeAfterLoginState extends State<HomeAfterLogin> {
  Future<(List<Map<String, dynamic>>, List<Map<String, dynamic>>)>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Map<String, dynamic>>, List<Map<String, dynamic>>)>
  _load() async {
    final enroll = await _getList(
      '/core/api/enrollments/',
    ); // ကိုယ့် enrollments
    final sessions = await _getList(
      '/core/api/sessions/',
    ); // permission အရ self-only ပြန်လာမယ်
    // upcoming အတွက် client-side filter (start_dt > now)
    final now = DateTime.now();
    final upcoming = sessions.where((s) {
      final sd = DateTime.parse(s['start_dt']);
      return sd.isAfter(now.subtract(const Duration(minutes: 1)));
    }).toList();
    return (enroll, upcoming);
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final res = await HttpX.get(path as Uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    }
    throw Exception('${res.statusCode}: ${res.body}');
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Learning')),
      body:
          FutureBuilder<
            (List<Map<String, dynamic>>, List<Map<String, dynamic>>)
          >(
            future: _future,
            builder: (_, snap) {
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());
              final (enrollments, sessions) = snap.data!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'My Courses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (enrollments.isEmpty) const Text('No enrollments yet.'),
                  for (final e in enrollments)
                    ListTile(
                      title: Text('Batch #${e["batch"]}'),
                      subtitle: Text('Status: ${e["status"]}'),
                      leading: const Icon(Icons.school),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upcoming Sessions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (sessions.isEmpty) const Text('No upcoming class.'),
                  for (final s in sessions) _sessionTile(s),
                ],
              );
            },
          ),
    );
  }

  Widget _sessionTile(Map s) {
    final start = DateTime.parse(s['start_dt']);
    final end = DateTime.parse(s['end_dt']);
    final hasClass = DateTime.now().isBefore(end);
    return Card(
      child: ListTile(
        title: Text('${s["course_title"] ?? "Session"} • ${s["status"]}'),
        subtitle: Text('${start.toLocal()} → ${end.toLocal()}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: hasClass ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            hasClass ? 'Available' : 'Passed',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        onTap: () => context.push('/session/${s["id"]}'),
      ),
    );
  }
}
