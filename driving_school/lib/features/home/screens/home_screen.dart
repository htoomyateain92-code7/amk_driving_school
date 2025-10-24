import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/profile_screen.dart';
import '../../blogs/repository/blog_repository.dart';
import '../../blogs/screens/blog_detail_screen.dart';
import '../../blogs/screens/blog_list_screen.dart';
import '../../courses/providers/course_providers.dart';
import '../../courses/screens/course_detail_screen.dart';
import '../../quizzes/repository/quiz_repository.dart';
import '../../quizzes/screens/quiz_list_screen.dart';
import '../../quizzes/screens/quiz_taking_screen.dart';
import '../../student_dashboard/screens/student_dashboard_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authStateProvider အစား authNotifierProvider ကိုသုံးသင့်ပါတယ်
    // ဒါမှ logout လုပ်ပြီးရင် UI က ချက်ချင်းပြောင်းမှာပါ
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      // AppBar တစ်ခုလုံးကို ဒီ code နဲ့ အစားထိုးပါ
      appBar: AppBar(
        title: const Text('AMK Driving School'),
        actions: [
          authState.when(
            // data state ကို (isLoggedIn, _) လို့ပြင်ပြီး error ကိုပါ handle လုပ်ပါ
            data: (isLoggedIn) {
              if (isLoggedIn) {
                // Login ဝင်ထားရင် Icon နှစ်ခုပြဖို့ Row ကိုသုံးပါ
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person),
                      tooltip: 'View Profile',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                      onPressed: () {
                        // Logout လုပ်မလုပ် confirmation dialog ပြပါ
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content:
                                const Text('Are you sure you want to log out?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                              TextButton(
                                child: const Text('Logout'),
                                onPressed: () async {
                                  Navigator.of(dialogContext)
                                      .pop(); // dialog ကိုအရင်ပိတ်
                                  // AuthNotifier ရဲ့ logout method ကိုခေါ်ပါ
                                  await ref
                                      .read(authNotifierProvider.notifier)
                                      .logout();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              } else {
                // Login မဝင်ထားရင် Login Button ပြပါ
                return TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: const Text('Login',
                      style: TextStyle(color: Colors.white)),
                );
              }
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
            ),
            error: (err, stack) => const Icon(Icons.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Featured Courses'),
            _buildCoursesSection(ref),
            _buildTappableSectionTitle(
              context,
              title: 'Latest Blogs',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BlogListScreen()));
              },
            ),
            _buildBlogsSection(ref),
            _buildSectionTitle('Available Quizzes'),
            _buildQuizzesSection(ref),
          ],
        ),
      ),
    );
  }

  Padding _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildCoursesSection(WidgetRef ref) {
    final coursesAsync = ref.watch(publicCoursesProvider);

    return coursesAsync.when(
      // 1. Data စောင့်နေတုန်း ဒီအပိုင်းက အလုပ်လုပ်ပါမယ်
      loading: () => const SizedBox(
        height: 200, // Card ရဲ့ အမြင့်အတိုင်း နေရာယူထားမယ်
        child: Center(child: CircularProgressIndicator()),
      ),

      // 2. API call မှာ error တက်သွားရင် ဒီအပိုင်းက အလုပ်လုပ်ပါမယ်
      error: (error, stackTrace) => SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Could not load courses: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      // 3. Data အောင်မြင်စွာရလာရင် ဒီအပိုင်းက အလုပ်လုပ်ပါမယ်
      data: (courses) => SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CourseDetailScreen(courseId: course.id)),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(right: 16),
                child: SizedBox(
                    width: 250, child: Center(child: Text(course.title))),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlogsSection(WidgetRef ref) {
    final blogsAsync = ref.watch(latestBlogsProvider);

    return blogsAsync.when(
      // 1. Loading State
      loading: () => const Center(child: CircularProgressIndicator()),

      // 2. Error State
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Could not load blogs: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      // 3. Data State
      data: (blogs) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: blogs.length > 3 ? 3 : blogs.length, // Show max 3 blogs
        itemBuilder: (context, index) {
          final blog = blogs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(blog.title),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BlogDetailScreen(blogId: blog.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizzesSection(WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider);
    return quizzesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child:
                Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (quizzes) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(quiz.title),
                  trailing: ElevatedButton(
                    // --- ဒီ onPressed logic ကို အသစ်ထည့်သွင်းလိုက်တာပါ ---
                    onPressed: () async {
                      // လက်ရှိ login ဝင်ထားမထားကို authNotifierProvider ကနေ စစ်ဆေးပါ
                      final isLoggedIn =
                          ref.read(authNotifierProvider).value ?? false;

                      if (isLoggedIn) {
                        // Login ဝင်ထားရင် QuizTakingScreen ကိုသွားပါ
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizTakingScreen(
                                  quizId: quiz.id, quizTitle: quiz.title),
                            ));
                      } else {
                        // Login မဝင်ထားရင် SnackBar ပြပြီး LoginScreen ကိုသွားခိုင်းပါ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please login to take a quiz.")),
                        );
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()));
                      }
                    },
                    child: const Text('Start Quiz'),
                  ),
                ),
              );
            }));
  }

  Widget _buildTappableSectionTitle(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          InkWell(
            onTap: onTap,
            child:
                const Text('View All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class StudentDashboardWithTabs extends StatefulWidget {
  const StudentDashboardWithTabs({super.key});
  @override
  State<StudentDashboardWithTabs> createState() =>
      _StudentDashboardWithTabsState();
}

class _StudentDashboardWithTabsState extends State<StudentDashboardWithTabs> {
  int _selectedIndex = 0;
  // Placeholder တွေအစား Screen အစစ်တွေကို ထည့်ပါ
  static const List<Widget> _widgetOptions = [
    StudentDashboardScreen(),
    QuizListScreen(),
    BlogListScreen(),
    ProfileScreen()
  ];
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined), label: 'Quizzes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined), label: 'Blogs'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // 4 items or more need this
      ),
    );
  }
}
