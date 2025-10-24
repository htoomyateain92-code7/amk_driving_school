import 'package:driving_app/src/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/responsive_center.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AuthController ရဲ့ state အပြောင်းအလဲကို စောင့်ကြည့်မယ်
    final authState = ref.watch(authControllerProvider);

    // Error message ပြစရာရှိရင် ပြပေးဖို့
    ref.listen(authControllerProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ResponsiveCenter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 16),
              TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Loading ဖြစ်နေရင် button ကို disable လုပ်ထားမယ်
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          ref.read(authControllerProvider.notifier).login(
                                usernameController.text.trim(),
                                passwordController.text.trim(),
                              );
                        },
                  child: authState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
