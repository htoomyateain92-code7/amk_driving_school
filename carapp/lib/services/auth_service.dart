import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _authTokenKey = 'access_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    print('✅ AuthService: Token Saved with key: $_authTokenKey');
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();

    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    print('❌ AuthService: Token Removed (Logged out)');
  }
}
