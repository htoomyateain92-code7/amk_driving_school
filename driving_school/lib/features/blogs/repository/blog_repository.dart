import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../models/blog_model.dart';

class BlogRepository {
  final _apiClient = ApiClient();
  Future<List<Blog>> fetchLatestBlogs() async {
    final response = await _apiClient.dio.get('/api/v1/articles/');
    return (response.data as List).map((json) => Blog.fromJson(json)).toList();
  }

  Future<Blog> fetchBlogDetail(int blogId) async {
    final response = await _apiClient.dio.get('/api/v1/articles/$blogId/');
    return Blog.fromJson(response.data);
  }
}

final blogRepositoryProvider = Provider((ref) => BlogRepository());
final latestBlogsProvider = FutureProvider(
    (ref) => ref.watch(blogRepositoryProvider).fetchLatestBlogs());

final blogDetailProvider = FutureProvider.family<Blog, int>((ref, blogId) {
  return ref.watch(blogRepositoryProvider).fetchBlogDetail(blogId);
});
