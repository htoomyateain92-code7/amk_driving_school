// lib/screens/dashboards/student_dash.dart
import 'package:driving_school/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/api.dart';
import '../../widgets/section_header.dart';

class StudentDash extends StatefulWidget {
  const StudentDash({super.key});
  @override
  State<StudentDash> createState() => _StudentDashState();
}

class _StudentDashState extends State<StudentDash> {
  bool loading = true;
  List sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await api.get(
        "/sessions?date=${DateTime.now().toIso8601String().split('T')[0]}",
      );
      setState(() {
        sessions = r.data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SectionHeader(title: "Today's Classes"),
                  const SizedBox(height: 12),
                  ...sessions.map((s) {
                    final start = DateTime.parse(s['start_dt']).toLocal();
                    final end = DateTime.parse(s['end_dt']).toLocal();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TrueGlass(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['course_title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${DateFormat.Hm().format(start)} - ${DateFormat.Hm().format(end)}",
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              s['status'] == "completed"
                                  ? Icons.check_circle
                                  : Icons.schedule,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const SectionHeader(title: "Quick Links"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text("Quizzes"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text("Articles"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
