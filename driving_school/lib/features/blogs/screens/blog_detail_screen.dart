// lib/features/blogs/screens/blog_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/blog_repository.dart';

class BlogDetailScreen extends ConsumerWidget {
  final int blogId;
  const BlogDetailScreen({super.key, required this.blogId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogAsync = ref.watch(blogDetailProvider(blogId));
    return Scaffold(
      appBar: AppBar(title: const Text("Blog Details")),
      body: blogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (blog) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(blog.title,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              // Blog model မှာ body အပြည့်အစုံပါအောင် ပြင်ဖို့လိုပါမယ်
              Text(blog.summary),
            ],
          ),
        ),
      ),
    );
  }
}
