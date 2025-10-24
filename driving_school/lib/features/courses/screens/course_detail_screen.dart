// lib/features/courses/screens/course_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../auth/screens/login_screen.dart';
import '../../booking/screens/booking_screen.dart';

import '../models/course_model.dart';
import '../providers/course_providers.dart';

// 1. ConsumerWidget အစား ConsumerStatefulWidget ကို ပြောင်းပါ
class CourseDetailScreen extends ConsumerStatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  // 2. Batch list ကို ပြ/မပြ ထိန်းချုပ်မယ့် state variable
  bool _showBatches = false;

  Course get course => course;

  @override
  Widget build(BuildContext context) {
    // widget.courseId ကိုသုံးပြီး course detail ကို watch လုပ်ပါ
    final courseDetailAsync = ref.watch(courseDetailProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: courseDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (course) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text(course.code,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Colors.white70)),
                const SizedBox(height: 16),
                Text(course.description,
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 32),

                // 3. State ပေါ်မူတည်ပြီး UI ကို ပြောင်းလဲပြသပါ
                if (_showBatches)
                  // _showBatches က true ဖြစ်နေရင် Batch list ကိုပြပါ
                  _buildBatchesList(course.batches)
                else
                  // _showBatches က false (default) ဖြစ်နေရင် Button ကိုပြပါ
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _showBatches =
                              true; // Button နှိပ်ရင် state ကို true ပြောင်းပါ
                        });
                      },
                      child: const Text('View Available Batches & Enroll'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Batch list ကိုပြမယ့် UI ကို function သီးသန့်ခွဲထုတ်လိုက်ပါ
  Widget _buildBatchesList(List<Batch>? batches) {
    // ref ကို ဒီ function ထဲမှာ သုံးနိုင်ပါတယ်
    if (batches == null || batches.isEmpty) {
      return const Center(
          child: Text('No available batches at the moment.',
              style: TextStyle(color: Colors.white70)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Batches',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white)),
        const Divider(color: Colors.white30),
        ...batches.map((batch) => Card(
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(batch.title,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Expanded(
                  child: Text(
                      'Instructor: ${batch.instructor.username}\nStarts: ${batch.startDate}',
                      style: const TextStyle(color: Colors.white70)),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final isLoggedIn =
                        ref.read(authNotifierProvider).value ?? false;
                    if (isLoggedIn) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => BookingScreen(
                                  batchId: batch.id, course: course)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please login to enroll.")),
                      );
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    }
                  },
                  child: const Text('Enroll Now'),
                ),
              ),
            )),
      ],
    );
  }
}
