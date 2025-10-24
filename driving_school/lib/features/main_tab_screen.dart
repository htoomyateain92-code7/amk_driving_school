import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/providers/auth_providers.dart';
import 'auth/screens/profile_screen.dart';
import 'courses/screens/course_list_screen.dart';
import 'student_dashboard/screens/student_dashboard_screen.dart';

class MainTabScreen extends ConsumerWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
          body: Center(child: Text('Error loading profile. Please restart.'))),
      data: (user) {
        // User က student ဖြစ်ပြီး enrollment ရှိမှသာ Student Dashboard ကိုပြပါ
        if (user != null && user.role == 'student' && user.hasBookings) {
          return const StudentDashboardWithTabs();
        } else {
          // မဟုတ်ရင် ပုံမှန် Home Screen ကိုပြပါ
          return const DefaultHomeScreenWithTabs();
        }
      },
    );
  }
}

// ပုံမှန် Home Screen (သင်တန်းမအပ်ရသေးသူများ/Guest များအတွက်)
class DefaultHomeScreenWithTabs extends StatefulWidget {
  const DefaultHomeScreenWithTabs({super.key});
  @override
  State<DefaultHomeScreenWithTabs> createState() =>
      _DefaultHomeScreenWithTabsState();
}

class _DefaultHomeScreenWithTabsState extends State<DefaultHomeScreenWithTabs> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = [
    CourseListScreen(),
    Text('Blogs'),
    ProfileScreen()
  ];
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    const List<String> _titles = ['Available Courses', 'Blogs', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/app_logo.jpg'),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        // items list ကို ဒီမှာထည့်ပေးပါ
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Student Dashboard (သင်တန်းအပ်ပြီးသူများအတွက်)
class StudentDashboardWithTabs extends StatefulWidget {
  const StudentDashboardWithTabs({super.key});
  @override
  State<StudentDashboardWithTabs> createState() =>
      _StudentDashboardWithTabsState();
}

class _StudentDashboardWithTabsState extends State<StudentDashboardWithTabs> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = [
    StudentDashboardScreen(),
    Text('My Quizzes'),
    ProfileScreen()
  ];
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        // items list ကို ဒီမှာထည့်ပေးပါ
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Knownledges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            label: 'My Quizzes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
