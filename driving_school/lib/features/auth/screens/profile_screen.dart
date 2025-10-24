// lib/features/auth/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/screens/home_screen.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      // AppBar ကို MainTabScreen ကနေ ယူသုံးမှာဖြစ်လို့ ဒီမှာထည့်စရာမလိုတော့ပါ
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (user) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    user.username,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                Center(
                  child: Text(
                    user.role,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 40),
                const Divider(),
                // TODO: Add other profile items like "My Courses", "Settings"
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () async {
                    // Show confirmation dialog before logging out
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content:
                            const Text('Are you sure you want to log out?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text('Logout'),
                            onPressed: () async {
                              // အရေးကြီး: State ကို မပြောင်းခင် Navigation ကို အရင်လုပ်ပါ

                              // 1. Dialog ကို အရင်ပိတ်ပါ
                              Navigator.of(dialogContext).pop();

                              // 2. ProfileScreen ကနေထွက်ပြီး HomeScreen ကို အစကနေပြန်သွားပါ
                              //    ဒါမှ ProfileScreen က error မတက်တော့မှာပါ
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                                (Route<dynamic> route) =>
                                    false, // အနောက်က screen အားလုံးကို ရှင်းပစ်ပါ
                              );

                              // 3. အားလုံးပြီးမှ logout state ကို update လုပ်ပါ
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .logout();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
