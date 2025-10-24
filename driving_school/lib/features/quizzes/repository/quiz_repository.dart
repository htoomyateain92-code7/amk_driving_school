// lib/features/quizzes/repository/quiz_repository.dart

// Import Question model
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../models/question_model.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  final _apiClient = ApiClient();

  Future<List<Quiz>> fetchQuizzes() async {
    final response = await _apiClient.dio.get('/api/v1/quizzes/');
    return (response.data as List).map((json) => Quiz.fromJson(json)).toList();
  }

  // --- Functions အသစ်များ ---

  Future<int> startQuiz(int quizId) async {
    final response =
        await _apiClient.dio.post('/api/v1/quizzes/$quizId/start/');
    return response.data['submission_id'];
  }

  Future<List<Question>> fetchQuizQuestions(int submissionId) async {
    final response = await _apiClient.dio
        .get('/api/v1/submissions/$submissionId/questions/');
    return (response.data as List)
        .map((json) => Question.fromJson(json))
        .toList();
  }

  Future<void> submitAnswer({
    required int submissionId,
    required int questionId,
    int? selectedOptionId,
    List<int>? orderedItemIds,
  }) async {
    await _apiClient.dio
        .post('/api/v1/submissions/$submissionId/answer/', data: {
      'question_id': questionId,
      'selected_option_id': selectedOptionId,
      'ordered_item_ids': orderedItemIds,
    });
  }

  Future<Map<String, dynamic>> finishQuiz(int submissionId) async {
    final response =
        await _apiClient.dio.post('/api/v1/submissions/$submissionId/finish/');
    return response.data;
  }
}

final quizRepositoryProvider = Provider((ref) => QuizRepository());

final quizzesProvider = FutureProvider<List<Quiz>>((ref) {
  return ref.watch(quizRepositoryProvider).fetchQuizzes();
});
