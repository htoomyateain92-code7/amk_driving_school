// lib/screens/instructor_dashboard_screen.dart

import 'package:carapp/screens/course_selection_screen.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../widgets/custom_glass_app_bar.dart';
import '../widgets/glass_card.dart';
import '../models/dashboard_model.dart'; // InstructorDashboardData ပါဝင်သည်

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  String _selectedLanguage = 'MM';

  // 💡 [FIX 1] InstructorDashboardData အမျိုးအစားကို မှန်ကန်စွာ သုံးပါ
  late Future<InstructorDashboardData> _dashboardDataFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // 💡 [FIX 2] initState တွင် Data Fetching ကို စတင်ပါ
    _dashboardDataFuture = _apiService.fetchInstructorDashboardData();
  }

  void _handleLogout(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

    // 💡 Logout ကို ခေါ်သည်
    apiService.logout();

    // Navigation: Stack ရှင်းပြီး Home (CourseSelectionScreen) သို့ ပြန်သွားသည်
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CourseSelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logout Button
    final Widget logoutButton = TextButton.icon(
      onPressed: () => _handleLogout(context),
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
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
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

        // 💡 [FIX 3] FutureBuilder ဖြင့် Data Fetching ကို ကိုင်တွယ်ခြင်း
        child: FutureBuilder<InstructorDashboardData>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  // API Error Message ကို ပြပါ
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              );
            } else if (snapshot.hasData) {
              // Data အောင်မြင်စွာ ရရှိသောအခါ
              final InstructorDashboardData data = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildGreetingHeader(),
                    const SizedBox(height: kDefaultPadding * 1.5),
                    _buildScheduleCard(data), // 💡 Data ကို ထည့်သွင်းပါ
                    const SizedBox(height: kDefaultPadding * 1.5),
                    _buildBottomSections(data), // 💡 Data ကို ထည့်သွင်းပါ
                    const SizedBox(height: kDefaultPadding * 4),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'No dashboard data available.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
          },
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
  // 💡 [FIX 4] Data ကို parameter ဖြင့် လက်ခံပါ
  Widget _buildScheduleCard(InstructorDashboardData data) {
    final String title = _selectedLanguage == 'MM'
        ? 'ယနေ့အချိန်ဇယား'
        : "Today's Schedule";

    return GlassCard(
      borderWidth: 50,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
              data.schedule, // 💡 API Data ကို သုံးပါ
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
                      ? 'ယနေ့ - ဖေဖော်ဝါရီ ၄ ရက်' // 💡 API ကနေ လာမယ့်ရက်စွဲကို ပြင်ပေးပါ
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
  // 💡 [FIX 5] Data ကို parameter ဖြင့် လက်ခံပြီး၊ Sub-widgets များသို့ ပို့ပါ
  Widget _buildBottomSections(InstructorDashboardData data) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final Widget noteCard = _buildStudentNoteCard(data);
    final Widget tipsCard = _buildTipsCard(data);

    // ... (Layout Logic is correct) ...
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
  // 💡 [FIX 6] Data ကို parameter ဖြင့် လက်ခံပါ
  Widget _buildStudentNoteCard(InstructorDashboardData data) {
    final String title = _selectedLanguage == 'MM'
        ? 'ကျောင်းသား အမှတ်ပေးရန်'
        : 'Student Scores/Notes';

    return GlassCard(
      borderWidth: 50,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
              data.studentNote, // 💡 API Data ကို သုံးပါ
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
  // 💡 [FIX 7] Data ကို parameter ဖြင့် လက်ခံပါ
  Widget _buildTipsCard(InstructorDashboardData data) {
    final String title = _selectedLanguage == 'MM'
        ? 'တိုင်ပင်ကြံဉာဏ်များ'
        : 'Teaching Tips';

    return GlassCard(
      borderWidth: 0.5,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
                  ? 'ဖြေရှင်းရမည့် တိုင်ပင်ကြံဉာဏ် ${data.teachingTips} ခု ရှိသည်။' // 💡 API Data ကို သုံးပါ
                  : 'There are ${data.teachingTips} tips to review.',
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
    // ... (Code is correct) ...
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
