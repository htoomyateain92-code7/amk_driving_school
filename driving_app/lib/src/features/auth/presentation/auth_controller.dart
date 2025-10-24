import 'package:driving_app/src/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      ref.read(goRouterProvider).go('/courses');
    }
  }
}
