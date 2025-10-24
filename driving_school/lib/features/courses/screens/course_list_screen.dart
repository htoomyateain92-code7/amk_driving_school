import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/course_providers.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(publicCoursesProvider);

    return Scaffold(
      // AppBar ကို MainTabScreen ကနေ ယူသုံးမှာဖြစ်လို့ ဒီမှာထည့်စရာမလိုတော့ပါ
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3a1c71), Color(0xFFd76d77), Color(0xFFffaf7b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: coursesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (courses) {
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                // Card အဟောင်းအစား Card widget အသစ်ကိုသုံးပါ
                return CourseCard(
                  course: course,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(courseId: course.id),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 16),
            );
          },
        ),
      ),
    );
  }
}
