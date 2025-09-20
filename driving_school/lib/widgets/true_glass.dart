// lib/widgets/true_glass.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class TrueGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur; // backdrop blur power
  final int fillAlpha; // 0x00–0xFF (glass body)
  final int rimAlpha; // 0x00–0xFF (edge highlight)
  final EdgeInsets padding;
  final bool showNoise;

  const TrueGlass({
    super.key,
    required this.child,
    this.radius = 20,
    this.blur = 24,
    this.fillAlpha = 0x1F, // ~12% white body
    this.rimAlpha = 0x3A, // ~23% white rim
    this.padding = const EdgeInsets.all(16),
    this.showNoise = true,
  });

  @override
  Widget build(BuildContext context) {
    final fill = Color((fillAlpha << 24) | 0xFFFFFF);
    final rim = Color((rimAlpha << 24) | 0xFFFFFF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          // 1) Backdrop blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(color: Colors.transparent),
          ),

          // 2) Glass body
          Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(radius),
              // outer soft shadow
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: padding,
            child: child,
          ),

          // 3) Edge highlight (thin rim)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: rim, width: 1),
                  // inner highlight gradient (top-left bright → bottom-right dim)
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x22FFFFFF), Color(0x11000000)],
                  ),
                ),
              ),
            ),
          ),

          // 4) Very subtle noise overlay (optional)
          if (showNoise)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    // noise via ShaderMask using a simple linear gradient dither
                    // cheap & safe for web/mobile
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x05000000), // 2% black
                        Color(0x00000000),
                        Color(0x05000000),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
