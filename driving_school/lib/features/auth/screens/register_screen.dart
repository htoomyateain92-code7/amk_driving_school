// lib/features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

// Registration process ရဲ့ state ကို ထိန်းချုပ်ရန် provider
final _registerProvider =
    StateNotifierProvider<RegisterNotifier, AsyncValue<void>>((ref) {
  return RegisterNotifier(ref);
});

class RegisterNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  RegisterNotifier(this._ref) : super(const AsyncData(null));

  Future<void> register(
      {required String username,
      required String email,
      required String password}) async {
    state = const AsyncLoading();
    try {
      await _ref.read(authRepositoryProvider).register(
            username: username,
            email: email,
            password: password,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // Registration state ကို စောင့်ကြည့်ရန်
    ref.listen<AsyncValue<void>>(_registerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${state.error}')),
        );
      }
      if (!state.hasError && state.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration successful! Please login.')),
        );
        // အောင်မြင်ရင် LoginScreen ကို အလိုအလျောက်ပြန်သွားပါ
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });

    final registerState = ref.watch(_registerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      // Simple email validation
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Please enter a valid email address';
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  registerState.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(_registerProvider.notifier).register(
                                    username: usernameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                            }
                          },
                          child: const Text('Register'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
