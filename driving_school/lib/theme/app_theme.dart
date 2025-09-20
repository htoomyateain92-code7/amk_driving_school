import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const purple = Color(0xFF6C63FF);
  static const blue = Color(0xFF00B2FF);

  // Dark
  static const darkA = Color(0xFF14162A);
  static const darkB = Color(0xFF0E0F1A);

  // Light
  static const lightA = Color(0xFFF1F4FF); // light bluish white
  static const lightB = Color(0xFFEAFBFF);
  static const vividPurple = Color(0xFF6E60FF);
  static const vividBlue = Color(0xFF13B6FF);
}

/// ---------- Theme Builders ----------
ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(
      base.textTheme.apply(bodyColor: Colors.white),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.purple,
      secondary: AppColors.blue,
      surface: const Color(0x221C1C28),
      onSurface: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Color(0x26FFFFFF), // 15% white glass
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(
      base.textTheme.apply(bodyColor: AppColors.darkB),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.darkB,
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.purple,
      secondary: AppColors.blue,
      surface: const Color(0x0FFFFFFF), // tiny veil
      onSurface: AppColors.darkB,
    ),
    cardTheme: const CardThemeData(
      color: Color(0x26FFFFFF), // 15% white glass
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );
}

/// ---------- True Glass widget ----------
class TrueGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final int fillAlpha; // body transparency
  final int rimAlpha; // rim highlight
  final EdgeInsets padding;

  const TrueGlass({
    super.key,
    required this.child,
    this.radius = 20,
    this.blur = 24,
    this.fillAlpha = 0x26, // ~15% alpha
    this.rimAlpha = 0x3A, // ~23% alpha
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final fill = Color((fillAlpha << 24) | 0xFFFFFF);
    final rim = Color((rimAlpha << 24) | 0xFFFFFF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          // backdrop blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(color: Colors.transparent),
          ),
          // body
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
          // rim highlight
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: rim, width: 1),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x22FFFFFF), Color(0x11000000)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Gradient Background ----------
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.darkA, AppColors.darkB],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.lightA, AppColors.lightB],
              ),
      ),
      child: Stack(
        children: [
          if (isDark)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.9, -1.0),
                  end: Alignment(1.0, 0.9),
                  colors: [
                    Color(0xFF7B5CFF),
                    Color(0xFF5A46FF),
                    Color(0xFF13B6FF),
                    Color(0xFF0091FF),
                  ],
                  stops: [0.05, 0.35, 0.7, 0.95],
                ),
              ),
              foregroundDecoration: const BoxDecoration(
                color: Color(0x4D000000), // 30% dark veil
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.95, -1.0),
                  end: Alignment(1.0, 0.95),
                  colors: [
                    Color(0xFF8A7CFF),
                    Color(0xFF6E60FF),
                    Color(0xFF27BFFF),
                    Color(0xFF13A6FF),
                  ],
                  stops: [0.05, 0.35, 0.7, 0.95],
                ),
              ),
              foregroundDecoration: const BoxDecoration(
                color: Color(0x26FFFFFF), // 15% veil so it's not blinding
              ),
            ),
          child,
        ],
      ),
    );
  }
}
