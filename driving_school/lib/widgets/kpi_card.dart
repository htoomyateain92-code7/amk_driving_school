// lib/widgets/kpi_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String title, value;
  const KpiCard({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return TrueGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
