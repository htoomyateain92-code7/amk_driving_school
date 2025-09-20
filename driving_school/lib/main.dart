import 'package:driving_school/firebase_options.dart';
import 'package:driving_school/screens/auth/login_screen.dart';
import 'package:driving_school/screens/auth/register_screen.dart';
import 'package:driving_school/screens/guest/guest_home.dart';
import 'package:driving_school/screens/session_detail.dart';
import 'package:driving_school/services/endpoints.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_after_login.dart';
import 'services/push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Only run push on mobile for now
  await PushService.init(); // This will early-return on web (we'll add the guard below)

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/boot',
    routes: [
      GoRoute(path: '/boot', builder: (_, __) => const _Boot()),
      GoRoute(path: '/', builder: (_, __) => const GuestHome()),
      GoRoute(path: '/home', builder: (_, __) => const HomeAfterLogin()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      // e.g. deep link to session: /session/:id
      GoRoute(
        path: '/session/:id',
        builder: (_, s) =>
            SessionDetail(id: int.parse(s.pathParameters['id']!)),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router);
}

class _Boot extends StatefulWidget {
  const _Boot({super.key});
  @override
  State<_Boot> createState() => _BootState();
}

class _BootState extends State<_Boot> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final access = await Endpoints.access; // Session ❌ → Endpoints ✅
    if (access != null) {
      // already logged in → go home
      if (mounted) context.go('/home');
    } else {
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
