import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Optional

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // API Endpoint Path
  static const String _registrationEndpoint = '/api/v1/device-registration/';

  // ✅ FIX: Platform ပေါ်မူတည်ပြီး Base URL ကို Dynamic သတ်မှတ်ခြင်း
  String get _baseUrl {
    if (kIsWeb) {
      // Web (Chrome) အတွက် localhost
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      // Android Emulator အတွက် 10.0.2.2 (Host PC ကို ရည်ညွှန်းရန်)
      return 'http://10.0.2.2:8000';
    } else {
      // iOS Simulator/Physical Device/Desktop အတွက် Default
      return 'http://127.0.0.1:8000';
    }
  }

  // Dynamic URL ကို Base URL နဲ့ Endpoint ကို ပေါင်းစပ်၍ ရယူခြင်း
  String get deviceRegistrationUrl => _baseUrl + _registrationEndpoint;

  void setupFcmHandlers() {
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("App launched from terminated state via Notification.");
        handleNotificationNavigation(message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification tapped while App is in background.");
      handleNotificationNavigation(message.data);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        "Notification received in foreground: ${message.notification?.title}",
      );
      // NOTE: Foreground မှာ Notification ပြဖို့အတွက် flutter_local_notifications လိုပါမယ်။
      handleNotificationNavigation(message.data);
    });
  }

  // User Login ပြီးနောက် Token ကို Backend သို့ ပို့ရန်
  Future<void> registerDeviceToken(String authToken) async {
    // 1. Permission တောင်းခံခြင်း
    NotificationSettings settings = await _fcm.requestPermission();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('Notification permission denied.');
      return;
    }

    // 2. Token ရယူခြင်း
    String? token = await _fcm.getToken();
    if (token == null) return;

    // 3. Platform သတ်မှတ်ခြင်း
    String platform;
    if (kIsWeb) {
      platform = 'web';
    } else if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    } else {
      // Choices error မဖြစ်စေရန် default တန်ဖိုး 'desktop' သို့မဟုတ် 'other' သုံးပါ။
      platform = 'desktop';
    }

    // 4. Django Backend သို့ POST Request ပို့ခြင်း
    try {
      print('Attempting to register FCM for $platform with token...');

      final response = await http.post(
        Uri.parse(deviceRegistrationUrl), // Dynamic URL ကို အသုံးပြု
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token, 'platform': platform}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCM Token registered successfully with Django for $platform.');
      } else {
        // Server ကနေ ပြန်လာတဲ့ အမှား Message ကို သေချာဖတ်ကြည့်ရန်
        print(
          'Failed to register FCM Token (Status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('HTTP error during FCM registration: $e');
    }
  }

  // Navigation Logic (Notification Data ကို ကိုင်တွယ်ခြင်း)
  static void handleNotificationNavigation(Map<String, dynamic> data) {
    if (data.containsKey('type')) {
      String type = data['type'];
      String? id = data.containsKey('course_id') ? data['course_id'] : null;

      print("Navigating based on type: $type, ID: $id");
    }
  }
}
