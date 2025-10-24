import 'package:flutter/material.dart';

class QuizTakingScreen extends StatelessWidget {
  const QuizTakingScreen({super.key, required this.submissionId});
  final int submissionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz in Progress')),
      body: Center(
        child: Text('Starting quiz with Submission ID: $submissionId'),
      ),
    );
  }
}
