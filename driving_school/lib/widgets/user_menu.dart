import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_state.dart';

class UserMenu extends ConsumerWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 12),
      color: Colors.black.withOpacity(.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (ctx) {
        if (!auth.isAuthed) {
          return [
            const PopupMenuItem(value: 'login', child: Text('Login')),
            const PopupMenuItem(value: 'register', child: Text('Register')),
          ];
        }
        return [
          PopupMenuItem(
            value: '__user__',
            enabled: false,
            child: Text(auth.username ?? 'User'),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'profile', child: Text('Profile')),
          const PopupMenuItem(value: 'logout', child: Text('Logout')),
        ];
      },
      onSelected: (val) async {
        switch (val) {
          case 'login':
            Navigator.of(context).pushNamed('/login');
            break;
          case 'register':
            Navigator.of(context).pushNamed('/register');
            break;
          case 'profile': // route later
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile coming soon')),
            );
            break;
          case 'logout':
            await ref.read(authProvider).logout();
            if (context.mounted) Navigator.of(context).pushNamed('/guest');
            break;
        }
      },
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white.withOpacity(.2),
        child: const Icon(Icons.person, size: 18),
      ),
    );
  }
}
