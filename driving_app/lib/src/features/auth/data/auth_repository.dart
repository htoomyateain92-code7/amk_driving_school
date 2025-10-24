import 'package:dio/dio.dart';
import 'package:driving_app/src/core/api/dio_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._dio);

  // Login successful ဖြစ်ရင် API token (String) ကိုပြန်ပေးမယ်
  Future<String> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/token/', // /v1 is now in the baseUrl
        data: {'username': username, 'password': password},
      );
      final token = response.data['access'];
      if (token == null) {
        throw 'Access token not found in response';
      }
      await _storage.write(key: 'auth_token', value: token);

      // After successful login, get FCM token and send to backend
      await _sendFcmTokenToBackend();

      return token;
    } on DioException catch (e) {
      // Provide more specific error messages based on the DioException type.
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw 'Connection timed out. Please check your network.';
      }
      if (e.type == DioExceptionType.connectionError) {
        throw 'Network error. Is the server running at http://10.0.2.2:8000?';
      }
      // If the server responded, use its error message.
      throw e.response?.data['detail'] ?? 'Login failed. Please try again.';
    }
  }

  Future<void> _sendFcmTokenToBackend() async {
    try {
      // Request permission for notifications (for iOS and web)
      await _firebaseMessaging.requestPermission();

      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print('FCM Token: $fcmToken');
        // Send this token to your Django backend using the correct endpoint
        // The endpoint is registered as 'device-registration' in core/urls.py
        // The serializer expects 'token' and 'platform'
        await _dio.post('/device-registration/',
            data: {'token': fcmToken, 'platform': 'android'});
      }
    } catch (e) {
      print('Failed to send FCM token: $e');
      // Handle error appropriately
    }
  }

  Future<void> logout() async {
    // TODO: Also call backend to delete the FCM token
    // final fcmToken = await _firebaseMessaging.getToken();
    // if (fcmToken != null) {
    //   await _dio.delete('/fcm-devices/delete_by_token/', data: {'token': fcmToken});
    // }
    await _storage.delete(key: 'auth_token');
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(dioProvider));
}

final isLoggedInProvider = FutureProvider.autoDispose<bool>((ref) async {
  // Asynchronously check if the token exists in secure storage.
  final token =
      await ref.watch(authRepositoryProvider)._storage.read(key: 'auth_token');
  return token != null;
});
