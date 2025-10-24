import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      // Use 10.0.2.2 for Android emulator to connect to host's localhost
      // Use localhost for iOS simulator.
      // Add /v1 prefix as requested.
      baseUrl: 'http://localhost:8000/api/v1',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // Add the interceptor to handle auth tokens
  dio.interceptors.add(ref.watch(dioInterceptorProvider));

  return dio;
}

@riverpod
InterceptorsWrapper dioInterceptor(Ref ref) {
  const storage = FlutterSecureStorage();

  return InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Get the token from secure storage
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        // Add the Authorization header if token exists
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options); // Continue with the request
    },
  );
}
