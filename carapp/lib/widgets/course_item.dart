// lib/widgets/course_item.dart

import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../constants/constants.dart';

class CourseItem extends StatelessWidget {
  final String duration;
  final String title;
  final String price;

  const CourseItem({
    super.key,
    required this.duration,
    required this.title,
    required this.price,
    required String buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurAmount: 5.0,
      opacity: 0.15,
      borderRadius: 15.0,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // သင်တန်း အချိန်/ခေါင်းစဉ်
            Text(
              '$duration | $title',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 5),

            // ဈေးနှုန်း
            Text(
              price,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(), // နေရာယူရန်
            // စာရင်းသွင်းရန် Button
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () {},
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
                child: const Text(
                  'စာရင်းသွင်းရန်',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
