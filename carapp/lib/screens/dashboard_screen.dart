// lib/screens/dashboard_screen.dart

import 'package:carapp/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/course_card.dart';
import '../widgets/info_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Glassmorphism ကို ပေါ်လွင်စေရန် Gradient Background ထည့်သွင်းခြင်း
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kGradientEnd], // ခရမ်းနု-ပန်းရောင်
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // CustomScrollView ဖြင့် App Bar ကို ဖန်တီးခြင်း
        child: CustomScrollView(
          slivers: <Widget>[
            // App Bar
            SliverAppBar(
              title: const Text(
                'My Learning Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(kDefaultPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header / Welcome Message
                  _buildHeader(),
                  const SizedBox(height: kDefaultPadding * 2),

                  // Courses Section (Responsive Grid)
                  _buildCoursesSection(),
                  const SizedBox(height: kDefaultPadding * 2),

                  // Info Section (Quiz & Blog)
                  _buildInfoSection(context),
                  const SizedBox(height: kDefaultPadding * 2),

                  // Extra UI: Upcoming Section
                  _buildUpcomingSection(context),
                  const SizedBox(height: kDefaultPadding * 4),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header Widget (ပုံထဲကလို နောက်ခံရှိတဲ့ Welcome Card) ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white12, // အရောင်ဖျော့ဖျော့
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: kGradientStart, size: 30),
          ),
          const SizedBox(width: kDefaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome back, Alex!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Ready for your next lesson?',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Courses Section (Responsive Grid) ---
  Widget _buildCoursesSection() {
    final List<Map<String, dynamic>> courses = [
      {
        'title': 'Flutter Development Masterclass',
        'progressText': '8 / 10 Lessons',
        'value': 0.8,
      },
      {
        'title': 'UI/UX Design Fundamentals',
        'progressText': '5 / 10 Lessons',
        'value': 0.5,
      },
      {
        'title': 'Dart Programming Basics',
        'progressText': '1 / 10 Lessons',
        'value': 0.1,
      },
      {
        'title': 'Backend with Firebase',
        'progressText': '3 / 10 Lessons',
        'value': 0.3,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Active Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: kDefaultPadding),

        LayoutBuilder(
          builder: (context, constraints) {
            // Screen Width ပေါ်မူတည်ပြီး Column အရေအတွက် ပြောင်းလဲခြင်း
            final int crossAxisCount = constraints.maxWidth > 900
                ? 3
                : (constraints.maxWidth > kMobileBreakpoint ? 2 : 1);

            // Card အချိုး (aspect ratio) ကိုလည်း ပြင်နိုင်သည်
            final double childAspectRatio =
                constraints.maxWidth < kMobileBreakpoint ? 1.5 : 1.2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: kDefaultPadding,
                mainAxisSpacing: kDefaultPadding,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseCard(
                  title: course['title'],
                  progressText: course['progressText'],
                  progressValue: course['value'],
                );
              },
            );
          },
        ),
      ],
    );
  }

  // --- Info Section (Responsive Row/Column) ---
  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extra Resources',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: kDefaultPadding),

        // Width 600px အောက်ဆို Column၊ ကျန်ရင် Row
        MediaQuery.of(context).size.width < kMobileBreakpoint
            ? Column(
                children: const [
                  InfoCard(title: 'Take a Quiz', icon: Icons.quiz),
                  SizedBox(height: kDefaultPadding),
                  InfoCard(title: 'Read Blog Posts', icon: Icons.article),
                ],
              )
            : Row(
                children: const [
                  Expanded(
                    child: InfoCard(title: 'Take a Quiz', icon: Icons.quiz),
                  ),
                  SizedBox(width: kDefaultPadding),
                  Expanded(
                    child: InfoCard(
                      title: 'Read Blog Posts',
                      icon: Icons.article,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  // --- Upcoming Section (ပုံထဲကလို အောက်ဆုံးက Item list) ---
  Widget _buildUpcomingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: kDefaultPadding),

        // List ကို Glass Card ထဲမှာ ထည့်သွင်း
        GlassCard(
          blurAmount: 5.0,
          borderRadius: 15.0,
          opacity: 0.1,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _UpcomingItem(
                title: 'Final Exam: Flutter Dev',
                date: 'Nov 15, 2025',
                icon: Icons.calendar_today,
                color: Colors.redAccent,
              ),
              Divider(color: Colors.white24, height: 1),
              _UpcomingItem(
                title: 'Design Project Submission',
                date: 'Nov 20, 2025',
                icon: Icons.design_services,
                color: Colors.lightBlueAccent,
              ),
              Divider(color: Colors.white24, height: 1),
              _UpcomingItem(
                title: 'Live Q&A Session',
                date: 'Nov 25, 2025',
                icon: Icons.live_tv,
                color: Colors.greenAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Upcoming List ရဲ့ Item တစ်ခုချင်းစီအတွက် Helper Widget
class _UpcomingItem extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color color;

  const _UpcomingItem({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(date, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {},
    );
  }
}
