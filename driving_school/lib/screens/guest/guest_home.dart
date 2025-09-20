import 'package:driving_school/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_header.dart';
import '../../widgets/lesson_card.dart';
import '../../widgets/quiz_card.dart';

class GuestHome extends StatelessWidget {
  const GuestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AMk Driving School'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 16),
        child: ListView(
          children: [
            const SectionHeader(title: 'Popular Lessons'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(4, (i) => const LessonCard()),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Code of Conduct & Tips'),
            const SizedBox(height: 10),
            const LessonCard(),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Practice Quizzes'),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, __) => const QuizCard(),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: 6,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.purple),
              child: const Text('Register / Login to Enroll'),
            ),
          ],
        ),
      ),
    );
  }
}
