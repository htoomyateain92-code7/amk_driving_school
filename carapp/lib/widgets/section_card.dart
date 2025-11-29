// lib/widgets/section_card.dart

import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../constants/constants.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  final VoidCallback? onTap;

  const SectionCard({
    super.key,
    required this.title,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurAmount: 5.0,
      opacity: 0.1,
      borderRadius: 15.0,

      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: kDefaultPadding),

            // Item List များ
            ...items,
          ],
        ),
      ),
    );
  }
}

class SectionItem extends StatelessWidget {
  final String text;
  final String? date;

  const SectionItem({
    super.key,
    required this.text,
    this.date,
    required void Function() onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (date != null)
            Text(
              date!,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
