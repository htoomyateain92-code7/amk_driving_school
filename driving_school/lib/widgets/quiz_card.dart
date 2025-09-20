import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TrueGlass(
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
      ),
    );
  }
}
