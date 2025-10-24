import 'package:driving_app/src/features/courses/presentation/courses_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch() จะคอยฟังการเปลี่ยนแปลง state ของ controller
    final coursesState = ref.watch(coursesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      // coursesState.when() เป็นวิธีที่ง่ายที่สุดในการจัดการ 3 states
      body: coursesState.when(
        // 1. กำลังโหลดข้อมูล
        loading: () => const Center(child: CircularProgressIndicator()),

        // 2. โหลดข้อมูลผิดพลาด
        error: (err, stack) {
          // Handle DioException specifically for better error messages
          if (err is DioException) {
            final message = err.response?.data?['detail'] ??
                err.message ??
                'An unknown error occurred';
            return Center(child: Text('Error: $message'));
          }
          return Center(child: Text('Error: $err'));
        },

        // 3. โหลดข้อมูลสำเร็จ
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text('No courses found.'));
          }
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                title: Text(course.title),
                subtitle: Text(course.code),
                onTap: () {
                  context.go('/courses/${course.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
