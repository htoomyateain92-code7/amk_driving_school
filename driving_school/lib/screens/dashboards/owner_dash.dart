// lib/screens/dashboards/owner_dash.dart
import 'package:driving_school/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';
import '../../widgets/kpi_card.dart';

class OwnerDash extends StatelessWidget {
  const OwnerDash({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      appBar: AppBar(title: const Text("Owner Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SectionHeader(title: "KPIs"),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: KpiCard(title: "Students", value: "245"),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: KpiCard(title: "Revenue", value: "Ks 1.2M"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: "Manage Batches"),
            const SizedBox(height: 12),
            TrueGlass(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Batch A1 - Instructor: John Doe"),
                  SizedBox(height: 4),
                  Text("Aug–Oct, 30 Students"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
