// lib/features/auth/screens/profile_or_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class ProfileOrLoginScreen extends ConsumerWidget {
  const ProfileOrLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (isLoggedIn) {
        if (isLoggedIn) {
          return const ProfileScreen(); // Login ဝင်ထားရင် ProfileScreen ကိုပြမယ်
        } else {
          // Login မဝင်ထားရင် Login လုပ်ဖို့ တိုက်တွန်းတဲ့ UI ပြမယ်
          return Scaffold(
            appBar: AppBar(title: const Text('Guest Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Login to manage your profile and enrollments.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    },
                    child: const Text('Login / Register'),
                  )
                ],
              ),
            ),
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('Something went wrong')),
    );
  }
}
