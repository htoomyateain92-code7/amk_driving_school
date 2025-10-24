import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/blog_repository.dart';
import 'blog_detail_screen.dart';

class BlogListScreen extends ConsumerWidget {
  const BlogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogsAsync = ref.watch(latestBlogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blogs')),
      body: blogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (blogs) => ListView.builder(
          itemCount: blogs.length,
          itemBuilder: (context, index) {
            final blog = blogs[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(blog.title),
                subtitle: Text(blog.summary,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BlogDetailScreen(blogId: blog.id)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
