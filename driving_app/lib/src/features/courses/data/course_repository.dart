import 'package:driving_app/src/core/api/dio_client.dart';
import 'package:driving_app/src/features/courses/data/models/course_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

part 'course_repository.g.dart';

class CourseRepository {
  final Dio _dio;
  CourseRepository(this._dio);

  Future<List<Course>> fetchCourses() async {
    try {
      final response = await _dio.get('/courses/');
      final courses = (response.data as List)
          .map((courseJson) => Course.fromJson(courseJson))
          .toList();
      return courses;
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to fetch courses';
    }
  }

  Future<Course> fetchCourseById(int courseId) async {
    try {
      final response = await _dio.get('/courses/$courseId/');
      return Course.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to fetch course detail';
    }
  }
}

@riverpod
CourseRepository courseRepository(Ref ref) {
  return CourseRepository(ref.watch(dioProvider));
}
