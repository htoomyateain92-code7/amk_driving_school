// lib/widgets/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blurAmount;
  final double borderRadius;
  final double opacity;
  final Color borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.blurAmount = 10.0, // Blur ကို နည်းနည်းပိုများပါမယ်
    this.borderRadius = 15.0,
    this.opacity = 0.15, // ပုံထဲကလို ပိုဖျော့စေရန်
    this.borderColor = Colors.white24, // ပုံထဲကလို အဖြူ နည်းနည်းဖျော့တဲ့ Border
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }
}
