// lib/features/notifications/repository/notification_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _apiClient = ApiClient();

  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/notifications/');
      final List<dynamic> data = response.data;
      return data.map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final notificationRepositoryProvider =
    Provider((ref) => NotificationRepository());

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  // authStateProvider ကို watch လုပ်ထားတဲ့အတွက် logout လုပ်ရင် ဒီ provider လည်း auto refresh ဖြစ်သွားပါမယ်
  final isLoggedIn = ref.watch(authStateProvider).value ?? false;
  if (isLoggedIn) {
    return ref.watch(notificationRepositoryProvider).fetchNotifications();
  }
  return []; // Login မဝင်ထားရင် list အလွတ်ပြန်ပေးမယ်
});
