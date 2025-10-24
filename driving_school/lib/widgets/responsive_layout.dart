import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    required this.desktopBody,
  });

  // Breakpoint values
  static const int mobileMaxWidth = 600;
  static const int tabletMaxWidth = 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileMaxWidth) {
          return mobileBody;
        } else if (constraints.maxWidth < tabletMaxWidth) {
          return tabletBody ?? desktopBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}
