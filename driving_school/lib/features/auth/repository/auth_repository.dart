// lib/features/auth/repository/auth_repository.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  Future<void> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post('/api/v1/token/', data: {
        'username': username,
        'password': password,
      });

      await _apiClient.saveTokens(
        accessToken: response.data['access'],
        refreshToken: response.data['refresh'],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(
      {required String username,
      required String email,
      required String password}) async {
    try {
      await _apiClient.dio.post('/api/v1/accounts/register/', data: {
        'username': username,
        'email': email,
        'password': password,
      });
    } on DioException {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() {
    return _apiClient.getAccessToken();
  }

  Future<AppUser> fetchMe() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/accounts/me/');
      return AppUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Future<String?> getAccessToken() {
  //   return _apiClient.getAccessToken();
  // }
}
