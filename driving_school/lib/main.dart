import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'package:driving_school/features/auth/screens/login_screen.dart';
import 'package:driving_school/features/home/screens/home_screen.dart';
import 'package:driving_school/features/student_dashboard/screens/student_dashboard_screen.dart';

import 'package:driving_school/features/auth/providers/auth_providers.dart';

import 'firebase_options.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable:
        GoRouterRefreshStream(ref.read(authStateProvider.stream)),
    redirect: (BuildContext context, GoRouterState state) {
      if (authState.isLoading || authState.hasError) {
        return null;
      }

      final isLoggedIn = authState.valueOrNull != null;

      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      if (isLoggedIn && isGoingToLogin) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          // ဒီနေရာမှာ user profile provider ကိုသုံးပြီး ဘယ် screen ပြမလဲ ဆုံးဖြတ်နိုင်ပါတယ်
          final userProfile = ref.watch(userProfileProvider);
          return userProfile.when(
            data: (user) {
              if (user != null && user.role == 'student') {
                return const StudentDashboardScreen();
              }
              return const HomeScreen(); // Guest or unenrolled student
            },
            loading: () => const SplashScreen(),
            error: (err, stack) =>
                const HomeScreen(), // Error ဖြစ်ရင်လည်း Home ကိုပဲပြ
          );
        },
      ),
    ],
  );
});

// --- Main App ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AMK Driving School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        fontFamily: 'Padauk',
      ),
      routerConfig: router,
    );
  }
}

// Loading indicator ပြပေးမယ့် screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// GoRouter ကို Riverpod stream နဲ့ ချိတ်ဆက်ပေးတဲ့ Helper Class
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
