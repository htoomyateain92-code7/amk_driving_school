import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio = Dio();
  final _secureStorage = const FlutterSecureStorage();

  ApiClient() {
    _dio.options.baseUrl =
        kIsWeb ? "http://localhost:8000" : "http://10.0.2.2:8000";

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token;
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          token = prefs.getString('access_token');
        } else {
          token = await _secureStorage.read(key: 'access_token');
        }

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.endsWith('/token/refresh/')) {
          print("Access Token has expired. Refreshing token...");

          String? refreshToken;
          if (kIsWeb) {
            final prefs = await SharedPreferences.getInstance();
            refreshToken = prefs.getString('refresh_token');
          } else {
            refreshToken = await _secureStorage.read(key: 'refresh_token');
          }

          if (refreshToken != null) {
            try {
              // 3. Refresh token ကိုသုံးပြီး token အသစ်တောင်းခြင်း
              final refreshResponse = await _dio.post('/api/v1/token/refresh/',
                  data: {'refresh': refreshToken});
              final newAccessToken = refreshResponse.data['access'];

              // Token အသစ်ကို သိမ်းဆည်းခြင်း
              await _saveToken(
                  newAccessToken, null); // refresh token မပြောင်းလဲပါ
              print("Token refreshed successfully.");

              // 4. မူလ request ကို header အသစ်နဲ့ ပြန်လည်ကြိုးစားခြင်း (Retry)
              final originalRequestOptions = error.requestOptions;
              originalRequestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              // handler.resolve() ကိုသုံးပြီး request ကိုပြန်ပို့ပါ
              final retriedResponse = await _dio.fetch(originalRequestOptions);
              return handler.resolve(retriedResponse);
            } on DioException {
              // Refresh token ပါ သက်တမ်းကုန်သွားရင်တော့ logout လုပ်ရပါမယ်
              print("Refresh token is also invalid. Logging out.");
              await _deleteAllTokens();
              // TODO: Global logout state ကို trigger လုပ်ပါ (ဥပမာ: ref.invalidate(authStateProvider))
              return handler.reject(error); // မူလ error ကိုသာ ဆက်သွားခိုင်းပါ
            }
          }
        }
        return handler
            .next(error); // 401 မဟုတ်တဲ့ တခြား error ဆိုရင် ဆက်သွားခိုင်းပါ
      },
    ));
  }

  Dio get dio => _dio;

  // Token သိမ်းဆည်းရန် Helper Method
  Future<void> _saveToken(String? accessToken, String? refreshToken) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      if (accessToken != null)
        await prefs.setString('access_token', accessToken);
      if (refreshToken != null)
        await prefs.setString('refresh_token', refreshToken);
    } else {
      if (accessToken != null)
        await _secureStorage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null)
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  // Token အားလုံးဖျက်ရန် Helper Method
  Future<void> _deleteAllTokens() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    } else {
      await _secureStorage.deleteAll();
    }
  }

  // AuthRepository ကနေသုံးဖို့ public methods တွေ
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    await _saveToken(accessToken, refreshToken);
  }

  Future<void> deleteTokens() async {
    await _deleteAllTokens();
  }

  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } else {
      return await _secureStorage.read(key: 'access_token');
    }
  }
}
