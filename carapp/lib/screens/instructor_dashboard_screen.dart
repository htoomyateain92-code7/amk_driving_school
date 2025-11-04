// lib/screens/instructor_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/custom_glass_app_bar.dart';
import '../widgets/glass_card.dart';
import '../models/dashboard_model.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  String _selectedLanguage = 'MM';

  // Hardcoded Data (API ကနေ လာမည်ဟု ယူဆ)
  final InstructorDashboardData _dashboardData = InstructorDashboardData(
    schedule:
        'မနက် ၈:၀၀ မှ ၁၀:၀၀ - အခြေခံအုပ်စု (A)\nနေ့လယ် ၂:၀၀ မှ ၄:၀၀ - အဆင့်မြင့် ကျောင်းသား (စောသူ)',
    studentNote: 'ကျောင်းသား ၅ ဦး Quiz ဖြေဆိုရန် ကျန်ရှိနေသည်',
    teachingTips: 5,
  );

  @override
  Widget build(BuildContext context) {
    // Logout Button
    final Widget logoutButton = TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout, color: Colors.white, size: 18),
      label: Text(
        _selectedLanguage == 'MM' ? 'ထွက်ရန်' : 'Logout',
        style: const TextStyle(color: Colors.white),
      ),
    );

    return Scaffold(
      appBar: CustomGlassAppBar(
        selectedLanguage: _selectedLanguage,
        onLanguageChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLanguage = newValue;
            });
          }
        },
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: Colors.cyanAccent, size: 20),
            const SizedBox(width: 10),
            const Text(
              'ကားသင်တန်း ကျောင်း',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        loginButton: logoutButton,
        actions: [
          _buildDashboardMenu(),
          const SizedBox(width: kDefaultPadding / 2),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kGradientVia, kGradientEnd],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildGreetingHeader(),
              const SizedBox(height: kDefaultPadding * 1.5),
              _buildScheduleCard(),
              const SizedBox(height: kDefaultPadding * 1.5),
              _buildBottomSections(),
              const SizedBox(height: kDefaultPadding * 4),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header/Greeting ---
  Widget _buildGreetingHeader() {
    final String title = _selectedLanguage == 'MM'
        ? 'နည်းပြ Dashboard'
        : 'Instructor Dashboard';

    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // --- 1. Schedule Card ---
  Widget _buildScheduleCard() {
    final String title = _selectedLanguage == 'MM'
        ? 'ယနေ့အချိန်ဇယား'
        : "Today's Schedule";

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              _dashboardData.schedule,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white24),
            Row(
              children: [
                const Icon(Icons.today, color: Colors.cyanAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  _selectedLanguage == 'MM'
                      ? 'ယနေ့ - ဖေဖော်ဝါရီ ၄ ရက်'
                      : 'Today - Feb 4',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Bottom Sections (Student Notes & Tips) ---
  Widget _buildBottomSections() {
    final double screenWidth = MediaQuery.of(context).size.width;

    final Widget noteCard = _buildStudentNoteCard();
    final Widget tipsCard = _buildTipsCard();

    if (screenWidth < 900) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          noteCard,
          const SizedBox(height: kDefaultPadding),
          tipsCard,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: noteCard),
          const SizedBox(width: kDefaultPadding),
          Expanded(child: tipsCard),
        ],
      );
    }
  }

  // --- Student Note Card ---
  Widget _buildStudentNoteCard() {
    final String title = _selectedLanguage == 'MM'
        ? 'ကျောင်းသား အမှတ်ပေးရန်'
        : 'Student Scores/Notes';

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              _dashboardData.studentNote,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, color: Colors.cyanAccent),
              label: Text(
                _selectedLanguage == 'MM' ? 'မှတ်တမ်းပေးရန်' : 'Grade Now',
                style: const TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Tips Card ---
  Widget _buildTipsCard() {
    final String title = _selectedLanguage == 'MM'
        ? 'တိုင်ပင်ကြံဉာဏ်များ'
        : 'Teaching Tips';

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedLanguage == 'MM'
                  ? 'ဖြေရှင်းရမည့် တိုင်ပင်ကြံဉာဏ် ${_dashboardData.teachingTips} ခု ရှိသည်။'
                  : 'There are ${_dashboardData.teachingTips} tips to review.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, color: Colors.cyanAccent),
              label: Text(
                _selectedLanguage == 'MM' ? 'ဖြေရှင်းရန်' : 'View Tips',
                style: const TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dashboard Menu Bar ---
  Widget _buildDashboardMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'label': 'နည်းပြ Dashboard',
        'icon': Icons.dashboard,
        'isSelected': true,
      },
      {'label': 'ကျောင်းသားစာရင်း', 'icon': Icons.people, 'isSelected': false},
      {'label': 'Quiz မှတ်တမ်း', 'icon': Icons.receipt, 'isSelected': false},
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: menuItems.map((item) {
        final String label = _selectedLanguage == 'MM'
            ? item['label']
            : item['label'].split(' ')[0];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: TextButton.icon(
            onPressed: () {},
            icon: Icon(
              item['icon'],
              color: item['isSelected'] ? Colors.cyanAccent : Colors.white70,
              size: 18,
            ),
            label: Text(
              label,
              style: TextStyle(
                color: item['isSelected'] ? Colors.cyanAccent : Colors.white70,
                fontWeight: item['isSelected']
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: item['isSelected']
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
