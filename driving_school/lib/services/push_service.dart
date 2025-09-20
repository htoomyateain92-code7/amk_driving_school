// lib/services/push_service.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../services/endpoints.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

class PushService {
  static final _fcm = FirebaseMessaging.instance;
  static final _fln = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'class', // id
    'Class', // name
    description: 'Class schedule & reminders',
    importance: Importance.high,
  );

  /// Call once in main() **after** Firebase.initializeApp(...)
  static Future<void> init() async {
    // 🛑 Skip on web unless you’ve set up web push (service worker + VAPID)
    if (kIsWeb) return;

    // Enable auto init (safe)
    await _fcm.setAutoInitEnabled(true);

    // 1) Local notifications init
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        final sId = resp.payload;
        if (sId != null && sId.isNotEmpty) _openSessionDeepLink(sId);
      },
    );

    // 2) Android notification channel + runtime permission (Android 13+)
    final androidImpl = _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(_channel);
    // Android 13+ permission (no-op on older versions)
    await androidImpl?.requestNotificationsPermission();

    // 3) iOS: show notification while app is foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4) iOS runtime permissions (push + local)
    if (!kIsWeb && Platform.isIOS) {
      // Firebase push permission
      await _fcm.requestPermission(alert: true, badge: true, sound: true);

      // Local notifications permission (Darwin API v19.x)
      await _fln
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >() // ✅ ဒီလိုပြန်သုံး
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // 5) Handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
      final title = m.notification?.title ?? 'Class update';
      final body = m.notification?.body ?? '';
      final sessionId = (m.data['session_id'] ?? '').toString();

      await _fln.show(
        0, // you can rotate ids if you want multiple
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: sessionId,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      final sessionId = (m.data['session_id'] ?? '').toString();
      if (sessionId.isNotEmpty) _openSessionDeepLink(sessionId);
    });

    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      final sessionId = (initial.data['session_id'] ?? '').toString();
      if (sessionId.isNotEmpty) {
        unawaited(
          Future.delayed(const Duration(milliseconds: 300), () {
            _openSessionDeepLink(sessionId);
          }),
        );
      }
    }
  }

  /// Call right after login (access token ready)
  static Future<void> registerTokenToBackend() async {
    if (kIsWeb) return; // skip web
    final token = await _fcm.getToken();
    if (token == null || token.isEmpty) return;
    try {
      await Endpoints.registerDevice(token, Platform.isIOS ? 'ios' : 'android');
    } catch (_) {
      // log if needed
    }
  }

  static void _openSessionDeepLink(String sessionId) {
    final ctx = globalNavigatorKey.currentContext;
    if (ctx == null) return;
    GoRouter.of(ctx).push('/session/$sessionId');
  }
}
