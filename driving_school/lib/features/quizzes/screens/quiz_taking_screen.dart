import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question_model.dart';
import '../repository/quiz_repository.dart';
import 'quiz_result_screen.dart';

final quizQuestionsProvider =
    FutureProvider.family<List<Question>, int>((ref, submissionId) {
  // Use .watch() here as it should refetch if the submissionId changes (though it won't in this screen)
  return ref.watch(quizRepositoryProvider).fetchQuizQuestions(submissionId);
});

class QuizTakingScreen extends ConsumerStatefulWidget {
  final int quizId;
  final String quizTitle;
  const QuizTakingScreen(
      {super.key, required this.quizId, required this.quizTitle});

  @override
  ConsumerState<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends ConsumerState<QuizTakingScreen> {
  int? _submissionId;
  bool _isStarting = true; // Changed from _isLoading
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Map<int, int> _mcqAnswers = {};

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _startQuiz());
  }

  void _startQuiz() async {
    try {
      // Correctly call startQuiz from the repository using ref.read
      final subId =
          await ref.read(quizRepositoryProvider).startQuiz(widget.quizId);
      if (mounted) {
        setState(() {
          _submissionId = subId;
          _isStarting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStarting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to start quiz: $e")));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submitAndFinish(List<Question> questions) async {
    // Submit the last answer
    final lastQuestionId = questions[_currentPage].id;
    if (_mcqAnswers.containsKey(lastQuestionId)) {
      await ref.read(quizRepositoryProvider).submitAnswer(
            submissionId: _submissionId!,
            questionId: lastQuestionId,
            selectedOptionId: _mcqAnswers[lastQuestionId],
          );
    }
    // Finish the quiz
    final result =
        await ref.read(quizRepositoryProvider).finishQuiz(_submissionId!);
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => QuizResultScreen(result: result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isStarting) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.quizTitle)),
          body: const Center(child: Text("Starting Quiz...")));
    }
    if (_submissionId == null) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.quizTitle)),
          body: const Center(child: Text("Could not start quiz.")));
    }

    final questionsAsync = ref.watch(quizQuestionsProvider(_submissionId!));

    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle)),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error loading questions: $e")),
        data: (questions) {
          if (questions.isEmpty)
            return const Center(child: Text("This quiz has no questions."));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Question ${_currentPage + 1}/${questions.length}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 16)),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return _buildQuestionCard(question);
                  },
                ),
              ),
              _buildNavigationControls(questions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.text,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 24),
          if (question.qtype == "MCQ")
            ...question.options.map((option) => RadioListTile<int>(
                  title: Text(option.text,
                      style: const TextStyle(color: Colors.white)),
                  value: option.id,
                  groupValue: _mcqAnswers[question.id],
                  onChanged: (value) {
                    setState(() {
                      _mcqAnswers[question.id] = value!;
                    });
                  },
                )),
        ],
      ),
    );
  }

  Widget _buildNavigationControls(List<Question> questions) {
    bool isLastQuestion = _currentPage == questions.length - 1;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
                setState(() => _currentPage--);
              },
              child: const Text('Previous'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: (_mcqAnswers[questions[_currentPage].id] == null)
                ? null
                : () async {
                    if (isLastQuestion) {
                      await _submitAndFinish(questions);
                    } else {
                      await ref.read(quizRepositoryProvider).submitAnswer(
                            submissionId: _submissionId!,
                            questionId: questions[_currentPage].id,
                            selectedOptionId:
                                _mcqAnswers[questions[_currentPage].id],
                          );
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                      setState(() => _currentPage++);
                    }
                  },
            child: Text(isLastQuestion ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }
}
