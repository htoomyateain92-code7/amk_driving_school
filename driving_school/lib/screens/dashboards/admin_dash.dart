// lib/screens/dashboards/admin_dash.dart
import 'package:driving_school/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';

class AdminDash extends StatefulWidget {
  const AdminDash({super.key});

  @override
  State<AdminDash> createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  final weekdays = <int>{};
  TimeOfDay? start;
  int duration = 60;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SectionHeader(title: "Generate Sessions"),
            const SizedBox(height: 12),
            TrueGlass(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (i) {
                      final day = ["M", "T", "W", "T", "F", "S", "S"][i];
                      final selected = weekdays.contains(i);
                      return FilterChip(
                        label: Text(day),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            if (selected) {
                              weekdays.remove(i);
                            } else {
                              weekdays.add(i);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => start = picked);
                    },
                    child: Text(
                      start == null
                          ? "Pick start time"
                          : "Start: ${start!.format(context)}",
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<int>(
                    value: duration,
                    items: const [
                      DropdownMenuItem(value: 60, child: Text("60 min")),
                      DropdownMenuItem(value: 90, child: Text("90 min")),
                    ],
                    onChanged: (v) => setState(() => duration = v ?? 60),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      // TODO: call /sessions/generate API
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Generate API call")),
                      );
                    },
                    child: const Text("Generate Sessions"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: "Pending Approvals"),
            const SizedBox(height: 12),
            TrueGlass(
              child: Column(
                children: const [Text("Instructor Request: Jane Doe")],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
