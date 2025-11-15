import 'package:carapp/models/dashboard_model.dart';
import 'package:carapp/screens/course_selection_screen.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../widgets/custom_glass_app_bar.dart';
import '../widgets/glass_card.dart';

// 💡 [FIX]: Management Screens များကို Import လုပ်ပါ
import 'management_screens/course_management_screen.dart';
// import 'management_screens/quiz_management_screen.dart'; // [TODO]
// import 'management_screens/blog_management_screen.dart'; // [TODO]
// import 'management_screens/session_management_screen.dart'; // [TODO]

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  String _selectedLanguage = 'MM';
  final ApiService _apiService = ApiService();
  late Future<OwnerDashboardData> _dashboardDataFuture;

  // --- Management List ---
  final List<Map<String, dynamic>> _managementItems = [
    {
      'title': 'သင်တန်းများ စီမံခန့်ခွဲရန်',
      'icon': Icons.class_,
      'route': '/manage-courses',
      'color': Colors.lightGreen,
    },
    {
      'title': 'Quiz များ စီမံခန့်ခွဲရန်',
      'icon': Icons.quiz,
      'route': '/manage-quizzes',
      'color': Colors.orangeAccent,
    },
    {
      'title': 'ဆောင်းပါးများ စီမံခန့်ခွဲရန်',
      'icon': Icons.article,
      'route': '/manage-blogs',
      'color': Colors.cyan,
    },
    {
      'title': 'သင်ကြားချိန်များ စီမံခန့်ခွဲရန်',
      'icon': Icons.schedule,
      'route': '/manage-sessions',
      'color': Colors.pinkAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _apiService.fetchOwnerDashboardData();
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

  // 💡 Navigation Logic Method (CRUD Management Screens များသို့ သွားရန်)
  void _navigateToManagementScreen(String route) {
    if (route == '/manage-courses') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CourseManagementScreen()),
      );
    }
    // [TODO]: ကျန်သော Screens များ ထပ်ထည့်ရန်
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation to $route is not yet implemented.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget logoutButton = TextButton.icon(
      onPressed: () => _handleLogout(context),
      icon: const Icon(Icons.logout, color: Colors.white, size: 18),
      label: const Text('ထွက်ရန်', style: TextStyle(color: Colors.white)),
    );

    // 💡 [FIX]: menuButton ကို build context ထဲတွင် ပြန်သတ်မှတ်ခြင်း
    // (final field အဖြစ် class အပြင်မှာ ကြေညာခြင်းက context မရှိသောကြောင့် Error ပေးနိုင်သည်)

    return Scaffold(
      drawer: _buildDrawer(), // Drawer ကို Scaffold နှင့် ချိတ်ဆက်

      appBar: CustomGlassAppBar(
        // 💡 [Note]: const ကို ဤနေရာတွင် ဖယ်ထားရပါမည်
        selectedLanguage: _selectedLanguage,
        onLanguageChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLanguage = newValue;
            });
          }
        },
        title: const Text('Owner Dashboard'),
        loginButton: logoutButton,
        actions: const [SizedBox(width: kDefaultPadding / 2)],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildGreetingHeader(),
              const SizedBox(height: kDefaultPadding * 1.5),
              _buildManagementGrid(context),
              const SizedBox(height: kDefaultPadding * 2),
              _buildStatsSection(),
              const SizedBox(height: kDefaultPadding * 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return const Text(
      'စီမံခန့်ခွဲသူ Dashboard',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // --- Management Grid (CRUD Buttons) ---
  Widget _buildManagementGrid(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth < 600 ? 2 : 4;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: kDefaultPadding,
      mainAxisSpacing: kDefaultPadding,
      children: _managementItems.map((item) {
        return _buildManagementCard(
          title: item['title'] as String,
          icon: item['icon'] as IconData,
          route: item['route'] as String,
          color: item['color'] as Color,
        );
      }).toList(),
    );
  }

  // --- Reusable Management Card ---
  Widget _buildManagementCard({
    required String title,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return GlassCard(
      blurAmount: 10.0,
      borderRadius: 15.0,

      padding: EdgeInsets.all(2),
      child: InkWell(
        onTap: () {
          _navigateToManagementScreen(route); // 💡 Navigation Logic ကို ခေါ်ပါ
        },
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dashboard Data/Stats Section and _buildStatsGrid/_buildStatCard are correct ---
  Widget _buildStatsSection() {
    return FutureBuilder<OwnerDashboardData>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'စာရင်းအချက်အလက်များ ခေါ်ယူရာတွင် Error ဖြစ်ပါသည်: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'အကျဉ်းချုပ် စာရင်းများ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: kDefaultPadding),
              _buildStatsGrid(data),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildStatsGrid(OwnerDashboardData data) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth < 600 ? 2 : 4;

    final List<Map<String, dynamic>> stats = [
      {
        'label': 'စုစုပေါင်း သင်တန်းသား',
        'value': data.totalStudents,
        'icon': Icons.people,
        'color': Colors.blueAccent,
      },
      {
        'label': 'နည်းပြ အရေအတွက်',
        'value': data.totalInstructors,
        'icon': Icons.person_pin,
        'color': Colors.orange,
      },
      {
        'label': 'တက်ကြွသော သင်တန်းများ',
        'value': data.activeCourses,
        'icon': Icons.school,
        'color': Colors.greenAccent,
      },
      {
        'label': 'ဝင်ငွေ (MMK)',
        'value': data.monthlyRevenue.toStringAsFixed(0),
        'icon': Icons.attach_money,
        'color': Colors.purpleAccent,
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: kDefaultPadding,
      mainAxisSpacing: kDefaultPadding,
      children: stats.map((stat) {
        return _buildStatCard(
          label: stat['label'] as String,
          value: stat['value'].toString(),
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
        );
      }).toList(),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      blurAmount: 10.0,
      borderRadius: 15.0,
      borderWidth: 50,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Drawer Widget ---
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: kGradientStart.withOpacity(0.9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: kGradientVia.withOpacity(0.7)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user,
                  color: Colors.cyanAccent,
                  size: 40,
                ),
                const SizedBox(height: 10),
                const Text(
                  'စီမံခန့်ခွဲသူ (Admin)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'User: Admin Name',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Management Menu Items
          ..._managementItems.map((item) {
            return ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop(); // Drawer ကို ပိတ်ပါ
                _navigateToManagementScreen(
                  item['route'] as String,
                ); // 💡 Navigation Logic ကို ခေါ်ပါ
              },
            );
          }).toList(),

          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'ထွက်ရန် (Logout)',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }
}
