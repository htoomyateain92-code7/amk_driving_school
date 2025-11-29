// lib/main.dart

// import 'package:carapp/auth_wrapper.dart';
import 'package:carapp/screens/course_selection_screen.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Production မှာ init လုပ်ဖို့လိုပါတယ်
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");

  // [TODO]: Data payload ကို ကိုင်တွယ်တဲ့ Logic ကို ဒီနေရာမှာ ရေးပါ
  FcmService.handleNotificationNavigation(message.data);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Firebase Core Initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Background Handler ကို Register လုပ်ခြင်း
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Foreground/Interaction Handlers တွေကို စတင်ခြင်း
  FcmService().setupFcmHandlers();
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
