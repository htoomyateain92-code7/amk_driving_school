import 'package:driving_school/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/auth_repo.dart';
import '../../services/push_service.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';

// screens/login.dart (essentials)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController(), _p = TextEditingController();
  bool _loading = false;
  String? _err;

  Future<void> _doLogin() async {
    setState(() => _loading = true);
    try {
      await AuthRepo().login(username: _u.text, password: _p.text);
      await PushService.registerTokenToBackend(); // 🔗 device register
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _err = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Login')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _u,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _p,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          if (_err != null)
            Text(_err!, style: const TextStyle(color: Colors.red)),
          FilledButton(
            onPressed: _loading ? null : _doLogin,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Login'),
          ),
          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text('Create account'),
          ),
        ],
      ),
    ),
  );
}
