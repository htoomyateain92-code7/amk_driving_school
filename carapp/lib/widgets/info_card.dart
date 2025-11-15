// lib/widgets/info_card.dart

import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'glass_card.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const InfoCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurAmount: 5.0,
      borderRadius: 15.0,
      opacity: 0.1,

      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          children: <Widget>[
            // Icon ကို ပုံထဲကလို အရောင်တောက်ပစေရန်
            Icon(icon, size: 30, color: Colors.yellowAccent),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
