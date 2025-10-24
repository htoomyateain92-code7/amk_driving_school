import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result['score'] ?? 0.0;
    final correct = result['correct'] ?? 0;
    final total = result['total'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: ${score.toStringAsFixed(1)}%',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 20),
            Text('You answered $correct out of $total questions correctly.',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white70)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
