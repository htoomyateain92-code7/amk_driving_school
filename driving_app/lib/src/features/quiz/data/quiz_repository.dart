import 'package:dio/dio.dart';
import 'package:driving_app/src/core/api/dio_client.dart';
import 'package:driving_app/src/features/quiz/data/models/quiz_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_repository.g.dart';

class QuizRepository {
  final Dio _dio;
  QuizRepository(this._dio);

  // Fetch all quizzes for a specific course
  Future<List<QuizInfo>> fetchQuizzesForCourse(int courseId) async {
    try {
      // Fetch quizzes from the top-level endpoint, filtering by course ID
      final response =
          await _dio.get('/quizzes/', queryParameters: {'course': courseId});
      final quizzes = (response.data as List)
          .map((quizJson) => QuizInfo.fromJson(quizJson))
          .toList();
      return quizzes;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to fetch quizzes';
    }
  }

  Future<QuizDetail> fetchQuizDetail(int quizId) async {
    try {
      final response = await _dio.get('/quizzes/$quizId/');
      return QuizDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to fetch quiz details';
    }
  }

  // Start a quiz and get a submission ID
  Future<int> startQuiz(int quizId) async {
    try {
      final response = await _dio.post('/quizzes/$quizId/start/');
      // Ensure the submission_id is parsed as an int, regardless of what the API returns.
      final submissionId = response.data['submission_id'];
      return int.parse(submissionId.toString());
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to start quiz';
    }
  }
}

@riverpod
QuizRepository quizRepository(Ref ref) {
  return QuizRepository(ref.watch(dioProvider));
}
