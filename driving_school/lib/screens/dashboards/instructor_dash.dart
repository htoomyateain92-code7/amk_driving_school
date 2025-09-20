import 'package:driving_school/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api.dart';
import 'package:intl/intl.dart';

class InstructorDash extends StatefulWidget {
  const InstructorDash({super.key});
  @override
  State<InstructorDash> createState() => _InstructorDashState();
}

class _InstructorDashState extends State<InstructorDash> {
  List items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await api.get('/sessions/today_for_teacher/');
      setState(() {
        items = r.data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      appBar: AppBar(title: const Text('Instructor Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final s = items[i];
                  final start = DateTime.parse(s['start_dt']).toLocal();
                  final end = DateTime.parse(s['end_dt']).toLocal();
                  return TrueGlass(
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
                                '${DateFormat.Hm().format(start)} – ${DateFormat.Hm().format(end)}',
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () {}, // open detail/attendance later
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.blue,
                          ),
                          child: const Text('Details'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
