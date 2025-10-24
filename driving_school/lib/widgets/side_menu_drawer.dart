import 'package:driving_school/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/providers/auth_providers.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/blogs/screens/blog_list_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/quizzes/screens/quiz_list_screen.dart';
import 'app_shell.dart';

class SideMenuDrawer extends ConsumerWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/app_logo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(), // Required child
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const AppShell(title: 'Home', body: HomeScreen())));
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
                      leading: const Icon(Icons.dashboard_outlined),
                      title: const Text('My Dashboard'),
                      onTap: () {
                        // This will navigate to the correct dashboard via main.dart's logic
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AuthWrapper()));
                      },
                    ),
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
