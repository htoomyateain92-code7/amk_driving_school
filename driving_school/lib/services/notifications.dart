import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'endpoints.dart';

class NotificationService {
  static final _fln = FlutterLocalNotificationsPlugin();

  /// 👇 ဒီ method ကို main.dart မှာခေါ်မယ်
  static Future<void> init() async {
    // Web ဖြစ်ရင် local notifications မသုံးပါ
    if (kIsWeb) {
      await FirebaseMessaging.instance.requestPermission();
      FirebaseMessaging.onMessage.listen((m) {
        // browser console သာပြချင်ရင် ဒီမှာ print လုပ်လို့ရတယ်
        // debugPrint('Web push: ${m.notification?.title}');
      });
      return;
    }

    // Android / iOS / desktop
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _fln.initialize(initSettings);

    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((m) async {
      final n = m.notification;
      if (n != null) {
        await _fln.show(
          0,
          n.title,
          n.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'general',
              'General',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  static Future<void> registerTokenWithServer() async {
    final tok = await FirebaseMessaging.instance.getToken();
    if (tok != null) {
      await Endpoints.registerDevice(
        tok,
        kIsWeb ? 'web' : (Platform.isIOS ? 'ios' : 'android'),
      );
    }
  }
}
