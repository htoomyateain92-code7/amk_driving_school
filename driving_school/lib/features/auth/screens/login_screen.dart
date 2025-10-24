// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main_tab_screen.dart';
import '../providers/auth_providers.dart';
import 'register_screen.dart';

// Login Notifier provider (အရင်အတိုင်း)
final _loginProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref);
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  LoginNotifier(this._ref) : super(const AsyncData(null));

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      await _ref.read(authRepositoryProvider).login(username, password);
      _ref.invalidate(authStateProvider);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Form ကို control လုပ်ဖို့ key တစ်ခုတည်ဆောက်ပါ
    final _formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen<AsyncValue<void>>(_loginProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${state.error}')),
        );
      }
      if (state is AsyncData && !state.isLoading) {
        // Login အောင်မြင်ရင် Main App Screen ကိုသွားပြီး history ရှင်းပါ
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainTabScreen()),
          (route) => false,
        );
      }
    });

    final loginState = ref.watch(_loginProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // 2. Form widget နဲ့ ပတ်လည်ကို wrap လုပ်ပါ
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Welcome Back',
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),

                  // 3. TextField အစား TextFormField ကိုပြောင်းသုံးပါ
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true),
                    // validator ထည့်ပါ
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true),
                    // validator ထည့်ပါ
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  loginState.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 15)),
                          onPressed: () {
                            // 4. Button နှိပ်ရင် form က valid ဖြစ်မဖြစ် စစ်ဆေးပါ
                            if (_formKey.currentState!.validate()) {
                              // Valid ဖြစ်မှ API call ကိုခေါ်ပါ
                              ref.read(_loginProvider.notifier).login(
                                    usernameController.text,
                                    passwordController.text,
                                  );
                            }
                          },
                          child: const Text('Login'),
                        ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()));
                    },
                    child: const Text("Don't have an account? Register",
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
