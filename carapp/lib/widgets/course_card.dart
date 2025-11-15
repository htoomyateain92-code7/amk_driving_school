// lib/widgets/course_card.dart

import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'glass_card.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String progressText;
  final double progressValue; // 0.0 to 1.0

  const CourseCard({
    super.key,
    required this.title,
    required this.progressText,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurAmount: 8.0,
      borderRadius: 15.0,
      opacity: 0.15, // နည်းနည်းပိုဖျော့

      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Course Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8.0,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.cyanAccent,
                    ), // progress အရောင်
                  ),
                ),

                const SizedBox(height: 5),
                // Progress Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${(progressValue * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Continue Button (Glass Effect အပြင်ဘက်မှာ ထားနိုင်သော်လည်း Card ထဲမှာပဲ ထားလိုက်သည်)
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // အဖြူရောင် Button
                foregroundColor: kGradientStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
