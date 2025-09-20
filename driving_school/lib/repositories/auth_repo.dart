import '../services/endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepo {
  static const _storage = FlutterSecureStorage();

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final data = await Endpoints.login(username, password);
    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;
    if (access == null || refresh == null) {
      throw Exception("Invalid login response: $data");
    }
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
  }

  Future<Map> me() => Endpoints.me();

  Future<void> register(String username, String password, {String? email}) =>
      Endpoints.register(username: username, password: password, email: email);

  Future<void> logout() async {
    await _storage.delete(key: 'access');
    await _storage.delete(key: 'refresh');
  }

  Future<String?> get access async => _storage.read(key: 'access');
  Future<String?> get refresh async => _storage.read(key: 'refresh');
}
