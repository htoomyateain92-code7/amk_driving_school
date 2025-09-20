// lib/services/api.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const kHost = 'localhost:8000'; // web runs against same host/port
const kBasePath = '/api';
const kBaseUrl = 'http://$kHost$kBasePath';
// Android emulator → 'http://10.0.2.2:8000/api'

final _storage = const FlutterSecureStorage();
final api = Api();

class Api {
  late final Dio _dio;
  Api() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (s) => s != null && s >= 200 && s < 400, // 201 accepted
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opt, handler) async {
          final acc = await _storage.read(key: 'access');
          if (acc != null) opt.headers['Authorization'] = 'Bearer $acc';
          handler.next(opt);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final r = await _storage.read(key: 'refresh');
            if (r != null) {
              try {
                final rr = await Dio(
                  BaseOptions(baseUrl: kBaseUrl),
                ).post('/accounts/auth/refresh/', data: {'refresh': r});
                await setToken(rr.data['access'], r);
                e.requestOptions.headers['Authorization'] =
                    'Bearer ${rr.data['access']}';
                final clone = await _dio.fetch(e.requestOptions);
                return handler.resolve(clone);
              } catch (_) {}
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String p, {Map<String, dynamic>? q}) =>
      _dio.get(p, queryParameters: q);
  Future<Response> post(String p, {dynamic data}) => _dio.post(p, data: data);

  Future<void> setToken(String access, String refresh) async {
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access');
    await _storage.delete(key: 'refresh');
  }
}
