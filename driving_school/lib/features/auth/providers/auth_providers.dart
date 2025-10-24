import 'package:flutter_riverpod/flutter_riverpod.dart';

// ဒီ import တွေက သင့် project မှာ ရှိပြီးသားလို့ ယူဆပါတယ်
import '../models/user_model.dart'; // AppUser model အတွက်
import '../repository/auth_repository.dart';

// 1. AuthRepository ကို provide လုပ်ရန် (ဒါက မူလအတိုင်း မှန်ပါတယ်)
final authRepositoryProvider = Provider((ref) => AuthRepository());

// 2. Auth State ကို စီမံခန့်ခွဲမယ့် StateNotifier
// App ရဲ့ login ဝင်/ထွက် အခြေအနေကို ဒီ provider တစ်ခုတည်းက ထိန်းချုပ်ပါမယ်
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  // .read() ကိုသုံးတာက မလိုအပ်ဘဲ provider ပြန် re-build ဖြစ်တာကို ကာကွယ်ပေးပါတယ်
  return AuthNotifier(ref.read, ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final Reader _read;
  final AuthRepository _authRepository;

  AuthNotifier(this._read, this._authRepository)
      : super(const AsyncValue.loading()) {
    _checkInitialAuthStatus();
  }

  // App စဖွင့်ချင်းမှာ သိမ်းထားတဲ့ token ရှိမရှိ စစ်ဆေးရန်
  Future<void> _checkInitialAuthStatus() async {
    try {
      final token = await _authRepository.getAccessToken();
      state = AsyncValue.data(token != null);
    } catch (e, st) {
      // token စစ်ဆေးရင်း error တက်ရင်လည်း logout ဖြစ်တယ်လို့ပဲ သတ်မှတ်လိုက်ပါ
      state = AsyncValue.data(false);
    }
  }

  // Login method
  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.login(username, password);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Logout method
  Future<void> logout() async {
    // loading state မပြဘဲ တန်းပြီး logout လုပ်လိုက်ပါ
    await _authRepository.logout();
    state = const AsyncValue.data(false);
  }
}

// 3. Login ဝင်ထားတဲ့ User ရဲ့ Profile Data ကို Fetch လုပ်ရန် Provider
// ဒီ Provider က အပေါ်က authNotifierProvider ရဲ့ အခြေအနေပေါ်မှာ မှီခိုပါတယ်
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // authNotifierProvider ကနေ login ဝင်ထားလား (true) မဝင်ထားဘူးလား (false) ဆိုတာကို စောင့်ကြည့်ပါ
  final isLoggedIn = ref.watch(authNotifierProvider).value;

  // အကယ်၍ login ဝင်ထားတယ်ဆိုရင်...
  if (isLoggedIn == true) {
    // AuthRepository ကနေ user data ကို fetch လုပ်ပါ
    return ref.watch(authRepositoryProvider).fetchMe();
  }

  // Login မဝင်ထားရင် null ပြန်ပေးပါ
  return null;
});
