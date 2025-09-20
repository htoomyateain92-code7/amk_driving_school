import 'package:driving_school/widgets/true_glass.dart';
import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({super.key});
  @override
  Widget build(BuildContext context) {
    return TrueGlass(
      fillAlpha: 0x26, // ≈15% white body
      rimAlpha: 0x40, // stronger rim
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Traffic Signs 101',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Basics, shapes & colors',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
