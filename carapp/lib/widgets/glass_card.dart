// lib/widgets/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget
  child; // 💡 [FIX]: Duplication များကို ရှင်းလင်းပြီး တစ်ကြိမ်သာ ကြေညာထားသည်။
  final double blurAmount;
  final double borderRadius;
  final double opacity;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child, // Child ကို တစ်ကြိမ်သာ တောင်းခံသည်။
    this.blurAmount = 10.0, // Blur ကို နည်းနည်းပိုများပါမယ်
    this.borderRadius = 15.0,
    this.opacity = 0.15, // ပုံထဲကလို ပိုဖျော့စေရန်
    this.borderColor = Colors.white24,
    this.borderWidth = 0.0,
    required EdgeInsets
    this.padding, // Default 0.0 ပေးထားခြင်းဖြင့် Error များကို ဖြေရှင်းပြီး
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
            // 💡 [FIX]: Border width ကို parameter မှ ယူသုံးလိုက်ပါပြီ။
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}
