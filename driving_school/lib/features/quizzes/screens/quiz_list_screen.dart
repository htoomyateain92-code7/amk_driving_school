import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../auth/screens/login_screen.dart';
import '../repository/quiz_repository.dart';
import 'quiz_taking_screen.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: quizzesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (quizzes) => ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(quiz.title),
                subtitle: Text('${quiz.questionCount} questions'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final isLoggedIn =
                        ref.read(authNotifierProvider).value ?? false;
                    if (isLoggedIn) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizTakingScreen(
                                quizId: quiz.id, quizTitle: quiz.title),
                          ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please login to take a quiz.")),
                      );
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    }
                  },
                  child: const Text('Start Quiz'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
