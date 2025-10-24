import 'package:driving_app/src/features/quiz/data/quiz_repository.dart';
import 'package:driving_app/src/features/quiz/data/models/quiz_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_controller.g.dart';

// Controller to fetch the list of quizzes for a course
@riverpod
class QuizzesForCourseController extends _$QuizzesForCourseController {
  @override
  FutureOr<List<QuizInfo>> build(int courseId) {
    return ref.read(quizRepositoryProvider).fetchQuizzesForCourse(courseId);
  }
}

@riverpod
class QuizDetailController extends _$QuizDetailController {
  @override
  FutureOr<QuizDetail> build(int quizId) {
    return ref.read(quizRepositoryProvider).fetchQuizDetail(quizId);
  }
}

// Using a class for the state is better for extensibility
class QuizStartState {
  const QuizStartState({
    this.loadingQuizId,
    this.result,
    this.error,
  });

  final int? loadingQuizId;
  final (int, int)? result; // (quizId, submissionId)
  final Object? error;

  QuizStartState copyWith({
    int? loadingQuizId,
    (int, int)? result,
    Object? error,
    bool forceError = false,
  }) {
    return QuizStartState(
      loadingQuizId: loadingQuizId ?? this.loadingQuizId,
      result: result ?? this.result,
      error: forceError ? error : error ?? this.error,
    );
  }
}

// Controller to handle the "Start Quiz" button state
@riverpod
class QuizStartController extends _$QuizStartController {
  @override
  QuizStartState build() {
    return const QuizStartState(); // Initial state
  }

  Future<void> startQuiz(int quizId) async {
    state = state.copyWith(loadingQuizId: quizId, error: null, forceError: true);
    final quizRepository = ref.read(quizRepositoryProvider);
    final value = await AsyncValue.guard(
      () => quizRepository.startQuiz(quizId),
    );
    if (value.hasError) {
      state = state.copyWith(loadingQuizId: null, error: value.error);
    } else {
      state = state.copyWith(
        loadingQuizId: null,
        result: (quizId, value.value!),
      );
    }
  }
}