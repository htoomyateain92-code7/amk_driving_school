// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/course_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving School UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // စာလုံးအရောင်များကို အဖြူရောင်စနစ်သို့ ပြောင်း
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        useMaterial3: true,
      ),
      home: const CourseSelectionScreen(),
    );
  }
}
