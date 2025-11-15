import 'package:carapp/screens/course_selection_screen.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../models/dashboard_model.dart';
import '../widgets/glass_card.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  // 💡 ပြင်ဆင်ချက် ၁: _apiService ကို late ဖြင့် ထားပါ
  late ApiService _apiService;
  // 💡 ပြင်ဆင်ချက် ၂: _dashboardData ကို Nullable (?) အဖြစ် ပြောင်းပါ (LateInitializationError ရှောင်ရန်)
  Future<StudentDashboardData>? _dashboardData;

  static const double _kCardBlurAmount = 10.0;
  static const double _kCardOpacity = 0.2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 💡 1. _apiService ကို Provider မှ ရယူခြင်း
    if (!mounted) return; // context မရှိတော့ရင် ရှောင်ရန်
    _apiService = Provider.of<ApiService>(context, listen: false);

    // 💡 2. Dashboard Data ကို ဤနေရာမှ စတင်ခေါ်ယူပါ
    // Null Check ကို လုံခြုံစွာ လုပ်ပါ
    if (_dashboardData == null) {
      _dashboardData = _apiService.fetchStudentDashboardData();
    }
  }

  // Logout Function (Menu မှ ခေါ်ရန်)
  void _handleLogout(BuildContext context) async {
    // 💡 await ကို သုံးပါ
    await _apiService.logout();

    // Navigation: Home Screen သို့ ပြန်သွားပြီး Navigation Stack အားလုံးကို ရှင်းလင်းပါ
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CourseSelectionScreen()),
      (Route<dynamic> route) =>
          false, // Navigation Stack အားလုံးကို ရှင်းလင်းသည်
    );
  }

  // 💡 Dashboard Data ကို Refresh လုပ်သော Function
  void _refreshDashboard() {
    setState(() {
      // 💡 Null မဟုတ်ကြောင်း သေချာပါက Assertion (!) ကို သုံးပါ
      _dashboardData = _apiService.fetchStudentDashboardData();
    });
  }

  // 💡 Course List Screen သို့ သွားသော Function
  void _navigateToCourseList() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const CourseSelectionScreen(),
          ),
        )
        .then((_) {
          // Course List မှ ပြန်လာလျှင် Dashboard ကို Refresh လုပ်ပါ
          _refreshDashboard();
        });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 ပြင်ဆင်ချက် ၃: _dashboardData null ဖြစ်နေရင် Loading ပြပါ
    if (_dashboardData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ကျောင်းသား Dashboard'),
        backgroundColor: kGradientStart,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'ထွက်ရန်',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCourseList,
        label: const Text('သင်တန်းစာရင်းကြည့်ရန်'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kGradientVia, kGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // 💡 FutureBuilder တွင် Null Assertion (!) ကို သုံးပါ
        child: FutureBuilder<StudentDashboardData>(
          future: _dashboardData!,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              final error = snapshot.error.toString();

              // 💡 401 Error ကို ကိုင်တွယ်ခြင်း
              if (error.contains('401')) {
                // BuildContext မပြီးခင် Navigation မဖြစ်စေဖို့ microtask သုံးခြင်း
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleLogout(context);
                });

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Text(
                      'Session သက်တမ်းကုန်သွားပါပြီ။ ချက်ချင်းဝင်ရောက်ပါ။',
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // 💡 အခြား Connection Error များအတွက်
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Text(
                    'Data ခေါ်ယူမှု မအောင်မြင်ပါ: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressCard(data),
                    const SizedBox(height: kDefaultPadding),
                    _buildSummaryGrid(data),
                    const SizedBox(height: kDefaultPadding * 2),
                    _buildUpcomingSessions(data.upcomingSessions),
                    const SizedBox(height: kDefaultPadding * 2),
                    _buildQuizScoreCard(data.lastQuizScore),
                    const SizedBox(height: 80), // FAB အတွက် နေရာချန်
                  ],
                ),
              );
            }
            return const Center(
              child: Text(
                'No data found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  // ... (UI Components များ) ...

  Widget _buildProgressCard(StudentDashboardData data) {
    final progress = data.progressPercentage / 100;

    return GlassCard(
      blurAmount: _kCardBlurAmount, // 💡 Added Blur
      opacity: _kCardOpacity, // 💡 Added Opacity
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'သင်တန်းတိုးတက်မှု အခြေအနေ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.cyanAccent,
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text(
              '${data.progressPercentage.toStringAsFixed(1)}% ပြီးစီးပြီ',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '${data.completedSessions} / ${data.totalSessions} Sessions ပြီးစီး',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(StudentDashboardData data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      crossAxisSpacing: kDefaultPadding,
      mainAxisSpacing: kDefaultPadding,
      children: [
        data.enrolledCourseCount == 0
            ? _buildActionTile(
                'သင်တန်း ရှာဖွေပါ',
                'သင်တန်း 0 ခု',
                Icons.search,
                Colors.yellowAccent,
                _navigateToCourseList,
              )
            : _buildInfoTile(
                'သင်တန်းအရေအတွက်',
                data.enrolledCourseCount.toString(),
                Icons.school,
                Colors.orangeAccent,
              ),
        _buildInfoTile(
          'ပြီးစီး Session',
          data.completedSessions.toString(),
          Icons.check_circle,
          Colors.lightGreenAccent,
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      blurAmount: _kCardBlurAmount,
      opacity: _kCardOpacity,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String actionTitle,
    String infoText,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GlassCard(
      blurAmount: _kCardBlurAmount,
      opacity: _kCardOpacity,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                infoText,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                actionTitle,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingSessions(List<StudentUpcomingSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'လာမည့် Sessions များ',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: kDefaultPadding),
        if (sessions.isEmpty)
          const Text(
            'လာမည့် Session မရှိသေးပါ၊ Booking ပြုလုပ်ပါ။',
            style: TextStyle(color: Colors.white70),
          )
        else
          ...sessions.map((session) => _buildSessionTile(session)).toList(),
      ],
    );
  }

  Widget _buildSessionTile(StudentUpcomingSession session) {
    String date = DateFormat('MMM dd, yyyy').format(session.startDt);
    String time = DateFormat('hh:mm a').format(session.startDt.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding / 2),
      child: GlassCard(
        borderRadius: 10,
        blurAmount: _kCardBlurAmount,
        opacity: _kCardOpacity,
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: ListTile(
          leading: Icon(
            Icons.calendar_today,
            color: Colors.cyanAccent.withOpacity(0.8),
          ),
          title: Text(
            session.batchTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '$date - $time (${session.status.toUpperCase()})',
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: () {
            // [TODO]: Session Detail Screen သို့ သွားရန်
          },
        ),
      ),
    );
  }

  Widget _buildQuizScoreCard(double? score) {
    return GlassCard(
      blurAmount: _kCardBlurAmount,
      opacity: _kCardOpacity,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          children: [
            const Icon(Icons.bar_chart, color: Colors.pinkAccent, size: 40),
            const SizedBox(width: kDefaultPadding),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'နောက်ဆုံး Quiz အမှတ်',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  score == null ? 'N/A' : '${score.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
