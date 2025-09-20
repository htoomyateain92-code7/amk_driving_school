import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/guest/guest_home.dart';
import '../screens/dashboards/owner_dash.dart';
import '../screens/dashboards/admin_dash.dart';
import '../screens/dashboards/instructor_dash.dart';
import '../screens/dashboards/student_dash.dart';
import '../state/auth_state.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/guest',
    refreshListenable: auth, // listen to login/logout
    routes: [
      GoRoute(path: '/guest', builder: (_, __) => const GuestHome()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/owner', builder: (_, __) => const OwnerDash()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDash()),
      GoRoute(path: '/instructor', builder: (_, __) => const InstructorDash()),
      GoRoute(path: '/student', builder: (_, __) => const StudentDash()),
    ],
    redirect: (ctx, state) {
      if (!auth.isAuthed) {
        // allow guest routes without login
        if (state.fullPath == '/login' ||
            state.fullPath == '/register' ||
            state.fullPath == '/guest') {
          return null;
        }
        return '/guest';
      }
      // role-based landing
      return switch (auth.role) {
        UserRole.owner => state.fullPath == '/owner' ? null : '/owner',
        UserRole.admin => state.fullPath == '/admin' ? null : '/admin',
        UserRole.instructor =>
          state.fullPath == '/instructor' ? null : '/instructor',
        UserRole.student => state.fullPath == '/student' ? null : '/student',
        _ => '/guest',
      };
    },
  );
});
