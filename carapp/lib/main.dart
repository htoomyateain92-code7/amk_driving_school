// lib/main.dart

import 'package:carapp/auth_wrapper.dart';
import 'package:carapp/screens/course_selection_screen.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApiService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving School UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Primary Color ကို Dark Indigo ဖြင့် သတ်မှတ်ခြင်း
        primarySwatch: Colors.indigo,
        primaryColor: Colors.indigo.shade900,
        appBarTheme: AppBarTheme(
          color: Colors.indigo.shade800,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        // စာလုံးအရောင်များကို ခြုံငုံ၍ အဖြူရောင်စနစ်သို့ ပြောင်း (AppBar အတွက်သာ အဓိက)
        // Body စာသားများကို အနက်ရောင်နီးပါး သုံးထားသည်
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        useMaterial3: true,
      ),
      home: const CourseSelectionScreen(),
    );
  }
}
