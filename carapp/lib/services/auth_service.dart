import 'package:shared_preferences/shared_preferences.dart';

// Token သိမ်းဆည်းခြင်း၊ စစ်ဆေးခြင်းနှင့် ဖယ်ရှားခြင်းတို့ကို လုပ်ဆောင်သော Service
class AuthService {
  // 💡 [FIX] Key Name ကို ApiService နှင့် ညီညွတ်စေရန် 'access_token' အဖြစ် ပြောင်းလဲထားသည်။
  static const String _authTokenKey = 'access_token';

  // Login အောင်မြင်ပါက Token ကို သိမ်းဆည်းခြင်း
  // (Note: သင့် ApiService ထဲက login() သည် ဤ method ကို ခေါ်သင့်သည် သို့မဟုတ်
  // ApiService က တိုက်ရိုက် SharedPreferences ကို ခေါ်သင့်သည်)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    print('✅ AuthService: Token Saved with key: $_authTokenKey');
  }

  // Token ကို ပြန်လည်ရယူခြင်း (API Header များတွင် သုံးရန်)
  // 💡 [getToken() အစား getAuthToken() အမည်ဖြင့် ပေးလိုက်ပါမည်၊ ဒါမှ ApiService
  // ထဲမှ getAccessToken() နှင့် ကွဲပြားသွားမည်။]
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // User Login ဝင်ပြီးပြီလား စစ်ဆေးခြင်း (Course Detail Screen တွင် သုံးရန်)
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    // Token ရှိပြီး စာသားပါဝင်မှသာ Login ဝင်သည်ဟု ယူဆသည်။
    return token != null && token.isNotEmpty;
  }

  // Logout လုပ်ပါက Token ကို ဖယ်ရှားခြင်း
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    print('❌ AuthService: Token Removed (Logged out)');
  }
}
