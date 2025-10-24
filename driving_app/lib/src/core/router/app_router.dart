import 'package:driving_app/src/features/auth/presentation/login_screen.dart';
import 'package:driving_app/src/features/courses/presentation/courses_screen.dart'; // import เพิ่ม
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:driving_app/src/features/booking/presentation/booking_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/courses/presentation/course_detail_screen.dart';
import '../../features/quiz/presentation/quiz_taking_screen.dart';
import 'dashboard_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/courses', // Start with public courses screen
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard', // New dashboard route
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesScreen(),
        routes: [
          // Nested Route
          GoRoute(
            path: ':courseId', // e.g., /courses/1
            builder: (context, state) {
              final courseId = int.parse(state.pathParameters['courseId']!);
              return CourseDetailScreen(courseId: courseId);
            },
            routes: [
              // Nested route for booking a batch
              GoRoute(
                path: 'book/:batchId', // e.g., /courses/1/book/2
                builder: (context, state) {
                  final courseId = int.parse(state.pathParameters['courseId']!);
                  final batchId = int.parse(state.pathParameters['batchId']!);
                  return BookingScreen(courseId: courseId, batchId: batchId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        // Path should match the one used in course_detail_screen.dart
        path: '/quiz/:quizId/take/:submissionId',
        builder: (context, state) {
          // We only need submissionId for the screen, but quizId is in the path
          final submissionId = int.parse(state.pathParameters['submissionId']!);
          return QuizTakingScreen(submissionId: submissionId);
        },
      ),
    ],
  );
}
