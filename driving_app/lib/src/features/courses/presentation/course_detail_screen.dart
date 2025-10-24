import 'package:driving_app/src/core/widgets/responsive_center.dart';
import 'package:driving_app/src/features/courses/presentation/course_detail_controller.dart';
import 'package:dio/dio.dart';
import 'package:driving_app/src/features/auth/data/auth_repository.dart';
import 'package:driving_app/src/features/quiz/data/models/quiz_models.dart';
import 'package:driving_app/src/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseState = ref.watch(courseDetailControllerProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: ResponsiveCenter(
        child: courseState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            if (err is DioException) {
              final message = err.response?.data?['detail'] ??
                  err.message ??
                  'An unknown error occurred';
              return Center(child: Text('Error: $message'));
            }
            return Center(child: Text('Error: $err'));
          },
          data: (course) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Chip(label: Text(course.code)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(course.description),
                  const SizedBox(height: 32),
                  Text("Available Batches",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (course.batches.isEmpty)
                    const Text("No available batches for this course yet.")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: course.batches.length,
                      itemBuilder: (context, index) {
                        final batch = course.batches[index];
                        return Card(
                          child: ListTile(
                            title: Text(batch.title),
                            subtitle:
                                Text("Instructor: ${batch.instructorName}"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Ensure path parameters are strings
                              context
                                  .go('/courses/${course.id}/book/${batch.id}');
                            },
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                  Text("Quizzes",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _QuizzesList(courseId: course.id), // Quiz list widget
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Private widget for displaying quizzes
class _QuizzesList extends ConsumerWidget {
  const _QuizzesList({required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesState =
        ref.watch(quizzesForCourseControllerProvider(courseId));

    ref.listen(quizStartControllerProvider, (previous, next) {
      if (next.error != null && previous?.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }
      if (next.result != null) {
        final (quizId, submissionId) = next.result!;
        context.go('/quiz/$quizId/take/$submissionId');
      }
    });

    return quizzesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Could not load quizzes: $err'),
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Text('No quizzes available for this course.');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return _QuizListItem(
                quiz: quiz); // Use a dedicated widget for each item
          },
        );
      },
    );
  }
}

// This new widget manages its own loading state
class _QuizListItem extends ConsumerWidget {
  const _QuizListItem({required this.quiz});
  final QuizInfo quiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizStartState = ref.watch(quizStartControllerProvider);
    // Watch the FutureProvider for the login state.
    final isLoggedInAsync = ref.watch(isLoggedInProvider);
    final isCurrentlyStarting = quizStartState.loadingQuizId == quiz.id;

    return Card(
      child: ListTile(
        title: Text(quiz.title),
        trailing: isLoggedInAsync.when(
          data: (isLoggedIn) {
            return ElevatedButton(
              onPressed: () {
                if (isCurrentlyStarting)
                  return; // Do nothing if already loading

                if (isLoggedIn) {
                  // If logged in, start the quiz
                  ref
                      .read(quizStartControllerProvider.notifier)
                      .startQuiz(quiz.id);
                } else {
                  // If not logged in, navigate to the login screen
                  context.go('/login');
                }
              },
              // Change button style and text based on login state
              style: !isLoggedIn
                  ? ElevatedButton.styleFrom(backgroundColor: Colors.grey)
                  : null,
              child: isCurrentlyStarting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isLoggedIn ? "Start" : "Login to Start"),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => const Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }
}
