import '../../../core/api_client.dart';
import '../models/course_model.dart';

class CourseRepository {
  final _apiClient = ApiClient();

  Future<List<Course>> fetchPublicCourses() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/courses/?public=true');
      final List<dynamic> data = response.data;
      return data.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Course> fetchCourseDetail(int courseId) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/courses/$courseId/');
      return Course.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
