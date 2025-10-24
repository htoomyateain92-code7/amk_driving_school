// lib/features/shell/side_menu_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers/auth_providers.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/profile_screen.dart';
import '../blogs/screens/blog_list_screen.dart';
import '../home/screens/home_screen.dart';
import '../quizzes/screens/quiz_list_screen.dart';
import '../student_dashboard/screens/student_dashboard_screen.dart';
import 'app_shell.dart';

class SideMenuDrawer extends ConsumerWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('/amk.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // သင်တောင်းဆိုထားတဲ့ App Logo
                Image.asset(
                  '/amk.png',
                  width: 1000,
                  height: 160,
                ),
                const Spacer(),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home / Dashboard'),
            onTap: () {
              Navigator.pop(context); // Drawer ကို အရင်ပိတ်ပါ
              final user = userProfile.value;
              // User ရဲ့ အခြေအနေပေါ်မူတည်ပြီး သက်ဆိုင်ရာ home screen ကိုသွားပါ
              if (user != null && user.role == 'student' && user.hasBookings) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AppShell(
                            title: 'Dashboard',
                            body: StudentDashboardScreen())));
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AppShell(title: 'Home', body: HomeScreen())));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: const Text('Quizzes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const QuizListScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Blogs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BlogListScreen()));
            },
          ),
          const Divider(),
          authState.when(
            data: (isLoggedIn) {
              if (isLoggedIn) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('My Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout',
                          style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(authNotifierProvider.notifier).logout();
                      },
                    ),
                  ],
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login / Register'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                );
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => const ListTile(title: Text("Error")),
          ),
        ],
      ),
    );
  }
}
