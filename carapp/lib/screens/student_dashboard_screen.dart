import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../screens/course_selection_screen.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../models/dashboard_model.dart';
import '../widgets/glass_card.dart';

// Localization Helper Function (All Keys Included)
String _localize(String key, {String locale = 'my'}) {
  final Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'student_dashboard': 'Student Dashboard',
      'progress_title': 'Course Progress Status',
      'completed_sessions': 'Completed Sessions',
      'total_sessions_completed': 'Sessions Completed',
      'search_course': 'Search Course',
      'course_count': 'Courses Enrolled',
      'upcoming_sessions_title': 'Upcoming Sessions',
      'no_upcoming_sessions': 'No upcoming sessions, please book one.',
      'last_quiz_score': 'Last Quiz Score',
      'logout_tooltip': 'Logout',
      'refresh_tooltip': 'Refresh',
      'view_courses': 'View Course List',
      'notification_tooltip': 'Notifications',
      'my_bookings_title': 'My Bookings',
      'no_bookings': 'No bookings found yet.',
      'booking_status_pending': 'Pending',
      'booking_status_confirmed': 'Confirmed',
      'booking_status_rejected': 'Rejected',
      'session_expired_login': 'Session expired. Please log in again.',
      'fetch_failed': 'Fetch failed',
      'no_data_found': 'No data found',
      'notification_screen_nav': 'Navigating to Notification Screen',
    },
    'my': {
      'student_dashboard': 'ကျောင်းသား Dashboard',
      'progress_title': 'သင်တန်းတိုးတက်မှု အခြေအနေ',
      'completed_sessions': 'ပြီးစီး Session',
      'total_sessions_completed': 'Sessions ပြီးစီး',
      'search_course': 'သင်တန်း ရှာဖွေပါ',
      'course_count': 'သင်တန်းအရေအတွက်',
      'upcoming_sessions_title': 'လာမည့် Sessions များ',
      'no_upcoming_sessions': 'လာမည့် Session မရှိသေးပါ၊ Booking ပြုလုပ်ပါ။',
      'last_quiz_score': 'နောက်ဆုံး Quiz အမှတ်',
      'logout_tooltip': 'ထွက်ရန်',
      'refresh_tooltip': 'Refresh',
      'view_courses': 'သင်တန်းစာရင်းကြည့်ရန်',
      'notification_tooltip': 'အကြောင်းကြားချက်များ',
      'my_bookings_title': 'သင်၏ Booking များ',
      'no_bookings': 'Booking စာရင်းမရှိသေးပါ။',
      'booking_status_pending': 'စောင့်ဆိုင်း',
      'booking_status_confirmed': 'အတည်ပြုပြီး',
      'booking_status_rejected': 'ငြင်းပယ်',
      'session_expired_login':
          'Session သက်တမ်းကုန်ဆုံးပါပြီ။ ကျေးဇူးပြု၍ ပြန်ဝင်ပါ။',
      'fetch_failed': 'ဆွဲယူမှု မအောင်မြင်ပါ',
      'no_data_found': 'အချက်အလက် မတွေ့ရှိပါ',
      'notification_screen_nav': 'Notification Screen သို့ သွားနေသည်',
    },
  };

  return localizedStrings[locale]?[key] ?? key;
}

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late ApiService _apiService;
  Future<StudentDashboardData>? _dashboardData;
  String _currentLocale = 'my';
  Future<List<Booking>>? _myBookings;

  static const double _kCardBlurAmount = 10.0;
  static const double _kCardOpacity = 0.2;

  int _unreadNotificationCount = 0;

  List<NotificationModel> _notifications = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;
    _apiService = Provider.of<ApiService>(context, listen: false);

    if (_dashboardData == null) {
      // ✅ FIX: စတင်ပွင့်သည်နှင့် Dashboard နှင့် Booking နှစ်မျိုးလုံးကို ခေါ်ယူရန်
      _loadDashboardData();
    }
  }

  // 💡 Dashboard နဲ့ Booking Data နှစ်မျိုးလုံးကို ခေါ်တဲ့ Function
  void _loadDashboardData() {
    setState(() {
      _dashboardData = _apiService.fetchStudentDashboardData();
      _myBookings = _apiService.fetchMyBookings();

      _fetchNotificationCount();
    });
  }

  Future<void> _fetchNotificationCount() async {
    try {
      // await Future.delayed(const Duration(milliseconds: 300));
      int count = await _apiService.fetchUnreadNotificationCount();

      if (mounted) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (e) {
      // Fetch fail လျှင် Error ကိုင်တွယ်ပါ
      if (mounted) {
        setState(() {
          _unreadNotificationCount = 0;
        });
      }
      print("Error fetching notification count: $e");
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      // [TODO]: ApiService တွင် fetchNotifications() function ကို ထည့်သွင်းရန် လိုအပ်သည်
      final notifs = await _apiService.fetchNotifications();
      setState(() {
        _notifications = notifs;
        _unreadNotificationCount = notifs.where((n) => !n.isRead).length;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  void _handleMarkAllRead() async {
    try {
      await _apiService.markAllNotificationsAsRead();
      // List ကို Local မှာ update လုပ်ပြီး UI ပြန်ဆွဲသည်
      setState(() {
        for (var n in _notifications) {
          n.isRead = true;
        }
        _unreadNotificationCount = 0;
      });
      Navigator.pop(context); // Dropdown ကို ပိတ်သည်
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All marked as read")));
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _navigateToNotifications() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _localize('notification_screen_nav', locale: _currentLocale),
        ),
      ),
    );
    try {
      await _apiService.markAllNotificationsAsRead();
    } catch (e) {
      print("Error marking all as read: $e");
    }
    _fetchNotificationCount();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All notifications cleared and count refreshed."),
      ),
    );
  }

  // Logout Function
  void _handleLogout(BuildContext context) async {
    await _apiService.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CourseSelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // 💡 Dashboard Data ကို Refresh လုပ်သော Function
  void _refreshDashboard() {
    _loadDashboardData();
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
          _refreshDashboard();
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    if (_dashboardData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _localize('student_dashboard', locale: _currentLocale),
        ), // ✅ FIX: Localized Title
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kGradientStart, kGradientVia, kGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          // 💡 Language ပြောင်းလဲရန် Button (ယာယီ)
          IconButton(
            icon: Text(
              _currentLocale == 'my' ? 'EN' : 'MY',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                _currentLocale = _currentLocale == 'my' ? 'en' : 'my';
              });
            },
          ),
          // ✅ Notification Icon (tooltip localized)
          Stack(
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.notifications),
                tooltip: _localize(
                  'notification_tooltip',
                  locale: _currentLocale,
                ),
                onOpened: () {
                  _fetchNotifications();
                },
                itemBuilder: (BuildContext context) {
                  if (_notifications.isEmpty) {
                    return [
                      const PopupMenuItem(
                        enabled: false,
                        child: Text("No notifications"),
                      ),
                    ];
                  }

                  // Notification List ကို Dropdown Items အဖြစ် ပြောင်းလဲခြင်း
                  List<PopupMenuEntry<String>> items = _notifications
                      .take(5)
                      .map((notif) {
                        return PopupMenuItem<String>(
                          value: notif.id.toString(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif!.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: notif.isRead
                                      ? Colors.black54
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                notif.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      })
                      .toList();

                  // Add "Mark All as Read" button at the bottom
                  items.add(
                    PopupMenuItem<String>(
                      value: 'mark_all',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.blue.withOpacity(0.1),
                        child: const Center(
                          child: Text(
                            "Mark All as Read",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                  return items;
                },
                onSelected: (String value) {
                  if (value == 'mark_all') {
                    _handleMarkAllRead();
                  } else {
                    // Individual Notification Click Logic (Optional)
                    print("Notification clicked: $value");
                  }
                },
              ),
            ],
          ),
          if (_unreadNotificationCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(maxWidth: 16, maxHeight: 16),
                child: Text(
                  _unreadNotificationCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                // textAlign: TextAlign.center,
              ),
            ),

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
            tooltip: _localize('refresh_tooltip', locale: _currentLocale),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: _localize('logout_tooltip', locale: _currentLocale),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCourseList,
        label: Text(_localize('view_courses', locale: _currentLocale)),
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
        child: FutureBuilder<StudentDashboardData>(
          future: _dashboardData!,
          builder: (context, snapshot) {
            // ... (Error handling is fine) ...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              // ... (401 Error handling code is fine) ...
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Text(
                    'Data ' +
                        _localize('fetch_failed', locale: _currentLocale) +
                        ': ${snapshot.error}',
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
                    _buildMyBookingsList(), // ✅ FIXED: Localization will now work here
                    const SizedBox(height: kDefaultPadding * 2),
                    _buildUpcomingSessions(data.upcomingSessions),
                    const SizedBox(height: kDefaultPadding * 2),
                    _buildQuizScoreCard(data.lastQuizScore),
                    const SizedBox(height: 80), // FAB အတွက် နေရာချန်
                  ],
                ),
              );
            }
            return Center(
              child: Text(
                _localize('no_data_found', locale: _currentLocale),
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  // ... (မူရင်း Code မှ မပြောင်းလဲသော _handleLogout, _refreshDashboard, _navigateToCourseList) ...

  // void _navigateToCourseList() {
  //   Navigator.of(context)
  //       .push(
  //         MaterialPageRoute(
  //           builder: (context) => const CourseSelectionScreen(),
  //         ),
  //       )
  //       .then((_) {
  //         _refreshDashboard();
  //       });
  // }

  // --- UI Components ---

  Widget _buildProgressCard(StudentDashboardData data) {
    // NaN (Not a Number) Error ရှောင်ရန် 0 ဖြင့် စစ်ခြင်း
    final progress = (data.totalSessions > 0)
        ? (data.progressPercentage / 100)
        : 0.0;

    return GlassCard(
      blurAmount: _kCardBlurAmount,
      opacity: _kCardOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localize('progress_title', locale: _currentLocale),
              style: const TextStyle(
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
              '${data.completedSessions} / ${data.totalSessions} ' +
                  _localize('total_sessions_completed', locale: _currentLocale),
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
                _localize('search_course', locale: _currentLocale),
                'သင်တန်း 0 ခု',
                Icons.search,
                Colors.yellowAccent,
                _navigateToCourseList,
              )
            : _buildInfoTile(
                _localize('course_count', locale: _currentLocale),
                data.enrolledCourseCount.toString(),
                Icons.school,
                Colors.orangeAccent,
              ),
        _buildInfoTile(
          _localize('completed_sessions', locale: _currentLocale),
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
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
        Text(
          _localize('upcoming_sessions_title', locale: _currentLocale),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: kDefaultPadding),
        if (sessions.isEmpty)
          Text(
            _localize('no_upcoming_sessions', locale: _currentLocale),
            style: const TextStyle(color: Colors.white70),
          )
        else
          ...sessions.map((session) => _buildSessionTile(session)).toList(),
      ],
    );
  }

  Widget _buildSessionTile(StudentUpcomingSession session) {
    // 💡 Locale အလိုက် Date/Time Format ပြောင်းလဲရန် (Optional)
    String dateFormat = _currentLocale == 'my' ? 'yyyy-MM-dd' : 'MMM dd, yyyy';
    String timeFormat = _currentLocale == 'my' ? 'HH:mm' : 'hh:mm a';

    String date = DateFormat(dateFormat).format(session.startDt);
    String time = DateFormat(timeFormat).format(session.startDt.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding / 2),
      child: GlassCard(
        borderRadius: 10,
        blurAmount: _kCardBlurAmount,
        opacity: _kCardOpacity,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          children: [
            const Icon(Icons.bar_chart, color: Colors.pinkAccent, size: 40),
            const SizedBox(width: kDefaultPadding),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localize('last_quiz_score', locale: _currentLocale),
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
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

  // ✅ NEW: Booking List Widget

  Widget _buildMyBookingsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localize('my_bookings_title', locale: _currentLocale), // ✅ FIX
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: kDefaultPadding),
        FutureBuilder<List<Booking>>(
          future: _myBookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                'Booking Data Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(
                _localize('no_bookings', locale: _currentLocale), // ✅ FIX
                style: const TextStyle(color: Colors.white70),
              );
            }

            final bookings = snapshot.data!;
            return Column(
              children: bookings
                  .map((booking) => _buildBookingTile(booking))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  // ✅ NEW: Booking Item Tile
  Widget _buildBookingTile(Booking booking) {
    final status = booking.status ?? 'unknown';
    String statusKey = 'booking_status_' + status.toLowerCase();
    String statusDisplay = _localize(
      statusKey,
      locale: _currentLocale,
    ); // ✅ FIX: Localize status

    Color statusColor = Colors.grey;
    if (booking.status == 'Confirmed') {
      statusColor = Colors.greenAccent;
    } else if (booking.status == 'Pending') {
      statusColor = Colors.orangeAccent;
    } else if (booking.status == 'Rejected') {
      statusColor = Colors.redAccent;
    }

    String formattedBookingDate = 'N/A';
    if (booking.createdAt != null) {
      try {
        final dateTime = DateTime.parse(booking.createdAt!);
        formattedBookingDate = DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        print("Date parsing error for createdAt: $e");
        formattedBookingDate = 'Invalid Date';
      }
    }
    String totalPrice = booking.totalPrice ?? 'N/A';
    String courseTitle = booking.courseTitle ?? 'Unknown Course';

    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding / 2),
      child: GlassCard(
        // ...
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListTile(
          leading: Icon(Icons.school, color: statusColor.withOpacity(0.8)),
          title: Text(
            booking.courseTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $formattedBookingDate | Price: $totalPrice',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              if (booking.bookedSessions.isNotEmpty)
                Text(
                  '1st Session: ${DateFormat('MMM dd, hh:mm a').format(booking.bookedSessions.first.startTime)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              Text(
                statusDisplay, // ✅ FIX: Display localized status
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
