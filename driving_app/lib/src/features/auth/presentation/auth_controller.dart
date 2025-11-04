import 'package:driving_app/src/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> login(String username, String password) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading(); // Loading state ကိုပြမယ်
    state = await AsyncValue.guard(
      () => authRepository.login(username, password),
    );

    if (!state.hasError) {
      final router = ref.read(goRouterProvider);

      // 🛑 ပြင်ဆင်ချက်- Navigation ကို ပိုမိုစိတ်ချရအောင် ပြုလုပ်ခြင်း။
      // `pop()` လုပ်လို့ရမလား အရင်စစ်ပါမယ်။ `login` screen ကို `push` or `go` နဲ့လာခဲ့ရင် `pop` လုပ်လို့ရပါမယ်။
      if (router.canPop()) {
        router.pop();
      } else {
        // `pop` လုပ်လို့မရတဲ့ အခြေအနေ (ဥပမာ- app စစဖွင့်ချင်း login screen ကို တန်းရောက်နေခဲ့ရင်)
        // home screen ('/courses') ကို `go` နဲ့ သွားပါမယ်။
        // `push` အစား `go` ကိုသုံးတာက navigation stack ကိုရှင်းပြီး home ကိုပဲထားခဲ့စေပါတယ်။
        router.go('/courses');
      }
    }
  }
}
