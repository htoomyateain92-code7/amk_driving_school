import 'package:driving_school/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _e = TextEditingController();
  final _p = TextEditingController();
  final _c = TextEditingController();

  bool _loading = false;
  bool _ob1 = true, _ob2 = true;
  bool _agree = false;

  @override
  void dispose() {
    _u.dispose();
    _e.dispose();
    _p.dispose();
    _c.dispose();
    super.dispose();
  }

  String? _req(String? v, {int min = 1}) {
    if (v == null || v.trim().length < min) return 'Required';
    return null;
  }

  String? _email(String? v) {
    if (v == null || v.isEmpty) return null; // optional email
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'Invalid email';
  }

  String? _pass(String? v) {
    if (v == null || v.length < 6) return 'Min 6 chars';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Policy')),
      );
      return;
    }
    if (_p.text != _c.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider)
          .register(
            username: _u.text.trim(),
            email: _e.text.trim().isEmpty ? null : _e.text.trim(),
            password: _p.text,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered! Please log in.")),
      );
      // Optional: auto-login
      // await ref.read(authProvider).login(_u.text.trim(), _p.text);

      // go to login
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: TrueGlass(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _u,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (v) => _req(v, min: 3),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _e,
                      decoration: const InputDecoration(
                        labelText: 'Email (optional)',
                      ),
                      validator: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _p,
                      decoration: InputDecoration(
                        labelText: 'Password (min 6)',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ob1 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _ob1 = !_ob1),
                        ),
                      ),
                      obscureText: _ob1,
                      validator: _pass,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _c,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ob2 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _ob2 = !_ob2),
                        ),
                      ),
                      obscureText: _ob2,
                      validator: _pass,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _agree,
                          onChanged: (v) => setState(() => _agree = v ?? false),
                        ),
                        const Expanded(
                          child: Text(
                            'I agree to the Terms & Privacy Policy',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(_loading ? 'Creating…' : 'Create Account'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
