// lib/widgets/course_features_widget.dart

import 'package:flutter/material.dart';

class CourseFeaturesWidget extends StatelessWidget {
  final List<String> features;

  const CourseFeaturesWidget({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'သင်တန်း၏ အဓိက အချက်အလက်များ မရှိသေးပါ။',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkmark Icon (အစိမ်းရောင်)
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF1E88E5), // Material Blue 500
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
