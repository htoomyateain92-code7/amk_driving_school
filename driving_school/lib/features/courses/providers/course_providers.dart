import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course_model.dart';
import '../repository/course_repository.dart';

final courseRepositoryProvider = Provider((ref) => CourseRepository());

final publicCoursesProvider = FutureProvider<List<Course>>((ref) {
  return ref.watch(courseRepositoryProvider).fetchPublicCourses();
});

final courseDetailProvider =
    FutureProvider.family<Course, int>((ref, courseId) {
  return ref.watch(courseRepositoryProvider).fetchCourseDetail(courseId);
});
