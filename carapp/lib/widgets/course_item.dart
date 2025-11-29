import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../constants/constants.dart';

class CourseItem extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final bool isPublished;
  final String studentCount;
  final String buttonText;
  final String description;

  final VoidCallback onTap;

  const CourseItem({
    super.key,
    required this.title,
    required this.duration,
    required this.price,
    required this.isPublished,
    required this.studentCount,
    required this.buttonText,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurAmount: 5.0,
      opacity: 0.15,
      borderRadius: 15.0,

      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$duration | $title',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 5),

            Text(
              price,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
