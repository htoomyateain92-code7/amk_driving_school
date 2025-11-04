// lib/screens/owner_dashboard_screen.dart

import '../services/api_service.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/custom_glass_app_bar.dart';
import '../widgets/glass_card.dart';
import '../models/dashboard_model.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  String _selectedLanguage = 'MM';

  late Future<OwnerDashboardData> _dashboardDataFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // 💡 API မှ Dashboard Data ကို စတင်ခေါ်ယူပါ
    _dashboardDataFuture = _apiService.fetchOwnerDashboardData();
  }

  // // 💡 API Call ကို စောင့်ဆိုင်းနေသည်ဟု ယူဆပြီး Hardcoded Data ကို ပြပါမည်
  // final OwnerDashboardData _dashboardData = OwnerDashboardData(
  //   totalRevenue: 5.6,
  //   totalStudents: 32,
  //   activeCourses: 5,
  // );

  @override
  Widget build(BuildContext context) {
    // 💡 Logout Button အတွက်
    final Widget logoutButton = TextButton.icon(
      onPressed: () {
        // Logout logic
      },
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
        loginButton: logoutButton, // Logout Button အစားထိုးခြင်း
        actions: [
          // Dashboard Menu Bar ကို ဤနေရာတွင် ထည့်ပါမည်
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
              FutureBuilder<OwnerDashboardData>(
                future: _dashboardDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return Column(
                      children: [
                        _buildMainDataCards(snapshot.data!),
                        const SizedBox(height: kDefaultPadding * 1.5),
                        _buildGraphPlaceholder(),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
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
        ? 'ပိုင်ရှင် Dashboard'
        : 'Owner Dashboard';

    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // 💡 Data ကို လက်ခံမယ့် _buildMainDataCards ကို ပြင်ဆင်ပါ
  Widget _buildMainDataCards(OwnerDashboardData data) {
    // ... (existing GridView implementation)
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth >= 900
        ? 3
        : (screenWidth > kMobileBreakpoint ? 2 : 1);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: kDefaultPadding,
        mainAxisSpacing: kDefaultPadding,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.3,
      ),
      children: [
        _buildRevenueCard(data), // Data ပို့
        _buildStudentsCard(data), // Data ပို့
        _buildCoursesCard(data), // Data ပို့
      ],
    );
  }

  // 💡 Cards များကို Data လက်ခံမည့်ပုံစံသို့ ပြင်ဆင်ခြင်း
  Widget _buildRevenueCard(OwnerDashboardData data) {
    final String title = _selectedLanguage == 'MM'
        ? 'စုစုပေါင်း ဝင်ငွေ (ယခုလ)'
        : 'Total Revenue (This Month)';
    final String revenue = '${data.totalRevenue.toStringAsFixed(1)} သိန်း';
    // ... (rest of the card implementation using 'revenue')
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
            const Spacer(),
            Text(
              revenue,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsCard(OwnerDashboardData data) {
    final String title = _selectedLanguage == 'MM'
        ? 'ကျောင်းသားသစ်'
        : 'New Students';
    final String students = '+ ${data.totalStudents} ဦး';

    return GlassCard(
      // ပုံထဲကလို Blue Gradient ရဖို့အတွက် Border Color ကို ပြောင်းသုံးနိုင်သည်
      borderColor: Colors.lightBlue.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const Spacer(),
            Text(
              students,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesCard(OwnerDashboardData data) {
    final String title = _selectedLanguage == 'MM'
        ? 'ဖွင့်လှစ်ထားသည့် သင်တန်းအရေအတွက်'
        : 'Active Courses';
    final String courses = '${data.activeCourses} ခု';

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
            const Spacer(),
            Text(
              courses,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Graph Placeholder Section ---
  Widget _buildGraphPlaceholder() {
    final String placeholderText = _selectedLanguage == 'MM'
        ? 'လစဉ်ဝင်ငွေ ဇယား (Simulation)'
        : 'Monthly Revenue Graph (Simulation)';

    return GlassCard(
      // Graph Placeholder Card ဟာ ပုံထဲမှာ ပိုကြီးတဲ့အတွက် Aspect Ratio ကို ချိန်ညှိပါ
      child: Container(
        padding: const EdgeInsets.all(kDefaultPadding),
        height: 350, // Card ရဲ့ အမြင့်ကို သတ်မှတ်ခြင်း
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, color: Colors.cyanAccent, size: 24),
            const SizedBox(width: 10),
            Text(
              placeholderText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
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
        'label': 'ပိုင်ရှင် Dashboard',
        'icon': Icons.dashboard,
        'isSelected': true,
      },
      {'label': 'ဝန်ထမ်းများ', 'icon': Icons.people, 'isSelected': false},
      {'label': 'စာရင်းဇယား', 'icon': Icons.settings, 'isSelected': false},
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: menuItems.map((item) {
        final String label = _selectedLanguage == 'MM'
            ? item['label']
            : item['label'].split(' ')[0]; // English တွင် ဥပမာ

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
              // Selected Item ကို Glass Background ပေးခြင်း
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
