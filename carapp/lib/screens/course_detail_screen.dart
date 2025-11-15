import 'package:carapp/models/course_model.dart';
import 'package:carapp/screens/login_screen.dart';
import 'package:carapp/screens/student_dashboard_screen.dart';
import 'package:flutter/material.dart';
// r
import '../constants/constants.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import '../models/course_detail_model.dart';
import '../services/auth_service.dart';

// Mobile breakpoint constant for responsive design
const double kMobileBreakpoint = 600.0;

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  final String title;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.title,
    Course? course, // 💡 title ကို required အဖြစ် ထည့်သွင်း
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService(); // 💡 AuthService instance

  late Future<CourseDetail> _courseDetailFuture;
  Future<List<CourseSession>>? _sessionsFuture;

  bool _isBooking = false;
  Set<int> _selectedSessionIds = {};

  @override
  void initState() {
    super.initState();
    // Step 1: Course Detail ကို အရင်ခေါ်ယူပါ
    _courseDetailFuture = _apiService.fetchCourseDetail(widget.courseId);

    // Step 2: Detail Future ပြီးဆုံးမှ Sessions ကို ထပ်ခေါ်ရန် Logic (batchIdToFetch ကို အသုံးပြု)
    _courseDetailFuture
        .then((courseDetail) {
          final int? batchId = courseDetail.batchIdToFetch;

          if (batchId != null && batchId > 0) {
            setState(() {
              _sessionsFuture = _apiService.fetchSessionsForBatch(batchId);
            });
          }
        })
        .catchError((error) {
          print(
            "Error fetching course detail for session initialization: $error",
          );
        });
  }

  // ဈေးနှုန်းကို Format လုပ်သော Method
  String _formatPrice(double priceValue) {
    if (priceValue <= 0.0) return 'အခမဲ့';

    final priceNum = priceValue.round();

    try {
      final formattedPrice = priceNum.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$formattedPrice ကျပ်';
    } catch (e) {
      return '${priceNum.toString()} ကျပ်';
    }
  }

  // Session ရွေးချယ်မှုကို ကိုင်တွယ်သော Method
  void _toggleSessionSelection(int sessionId) {
    setState(() {
      if (_selectedSessionIds.contains(sessionId)) {
        _selectedSessionIds.remove(sessionId);
      } else {
        _selectedSessionIds.add(sessionId);
      }
    });
  }

  // 💡 စာရင်းသွင်းခြင်း အောင်မြင်သည်/မအောင်မြင်သည်ကို ပြသသော Snackbar
  void _showSnackbar(String message, {Color color = Colors.red}) {
    // Check if the context is still valid before showing the snackbar
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // 💡 Booking API ကို ကိုင်တွယ်သော Method (Fix Logic ပါဝင်သည်)
  void _handleEnroll(int courseId, int? batchId) async {
    // ==========================================================
    // 1. AUTHENTICATION CHECK
    // ==========================================================
    // 💡 ပထမဆုံး ချက်ခြင်းစစ်ဆေးပါ။ (Delay မလုပ်တော့ပါ)
    bool loggedIn = await _authService.isLoggedIn();

    // 1.1. Login မဝင်ရသေးရင်
    if (!loggedIn) {
      // Login Modal ဖွင့်ရန်
      final bool? loginSuccess = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(isModal: true),
        ),
      );

      if (loginSuccess != true) {
        _showSnackbar('စာရင်းသွင်းရန်အတွက် ဦးစွာ Login ဝင်ရန် လိုအပ်ပါသည်။');
        return;
      }
    }

    // 1.2. 💡 Login ဝင်ပြီးသား သို့မဟုတ် Login အခုမှ ဝင်ပြီးသူဖြစ်ပါက
    // ချက်ချင်း Booking ကို မခေါ်သေးဘဲ Token ကို ဆွဲထုတ်ပြီး Auth ခိုင်မာကြောင်း အတည်ပြုပါ။
    String? token = await _authService
        .getAuthToken(); // 💡 AuthService မှ Token ကို တိုက်ရိုက်တောင်းသည်

    if (token == null || token.isEmpty) {
      // Token အမှန်တကယ် မတွေ့ရသေးပါက (နောက်ဆုံး Error ကို ပြသပြီး ရပ်သည်)
      _showSnackbar(
        'Login အောင်မြင်သော်လည်း၊ စာရင်းသွင်းရန်အတွက် Authorization token ကို ပြန်လည်အတည်မပြုနိုင်ပါ။ ကျေးဇူးပြု၍ ခဏကြာပြီးမှ ထပ်မံကြိုးစားပါ သို့မဟုတ် App ကို ပိတ်ပြီး ပြန်ဖွင့်ပါ။',
        color: Colors.red,
      );
      return;
    }

    // 💡 ဤနေရာသို့ ရောက်ပါက Token ရှိနေသည်မှာ သေချာပါသည်။
    // (ApiService ၏ _getHeaders() သည် ဤအချိန်၌ Token ကို သေချာပေါက် ရရှိသင့်ပါပြီ။)

    // ==========================================================
    // 2. PRE-BOOKING CHECKS (Auth ပြီးမှ စစ်ဆေး)
    // ==========================================================

    if (batchId == null || batchId == 0) {
      _showSnackbar('Batch အချက်အလက် မရှိခြင်းကြောင့် စာရင်းသွင်း၍ မရနိုင်ပါ။');
      return;
    }

    if (_selectedSessionIds.isEmpty) {
      _showSnackbar('သင်တန်း Session အနည်းဆုံးတစ်ခု ရွေးချယ်ရန် လိုအပ်ပါသည်။');
      return;
    }

    setState(() {
      _isBooking = true;
    });

    // ==========================================================
    // 3. CREATE BOOKING
    // ==========================================================
    try {
      // Booking API ခေါ်ဆိုမှု (ယခုအခါ ApiService သည် Header ထဲတွင် Token ကို သေချာပေါက် ရရှိပါမည်။)
      await _apiService.createBooking(
        _selectedSessionIds,
        courseId: courseId,
        batchId: batchId,
      );

      _showSnackbar(
        'သင်တန်းကို အောင်မြင်စွာ စာရင်းသွင်းပြီးပါပြီ။',
        color: Colors.green,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const StudentDashboardScreen(),
          ),
          (Route<dynamic> route) => false, // အရင် routes အားလုံးကို ဖျက်ပစ်သည်
        );
      }
    } catch (e) {
      print('Booking Error: $e');
      _showSnackbar(
        'Booking ပြုလုပ်ရာတွင် Error ဖြစ်ပေါ်ပါသည်။ Error: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < kMobileBreakpoint;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kGradientVia, kGradientEnd],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: SizedBox(
              width: isMobile ? screenWidth * 0.95 : 700,
              child: FutureBuilder<CourseDetail>(
                future: _courseDetailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print('Course Detail Error: ${snapshot.error}');
                    return Center(
                      child: Text(
                        'သင်တန်း အသေးစိတ် ခေါ်ယူရာတွင် Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final courseDetail = snapshot.data!;
                    return _buildDetailCard(context, courseDetail);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Course Detail Card UI ---
  Widget _buildDetailCard(BuildContext context, CourseDetail courseDetail) {
    final int? batchIdToPass = courseDetail.batchIdToFetch;

    return GlassCard(
      blurAmount: 15.0,
      opacity: 0.25,
      borderRadius: 20.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 1. ခေါင်းစဉ်
            _buildHeader(context, courseDetail),
            const SizedBox(height: kDefaultPadding * 1.5),

            // 2. သင်တန်းအသေးစိတ် ဖော်ပြချက်
            _buildCourseDescription(courseDetail),
            const SizedBox(height: kDefaultPadding * 2),

            // Features List
            const Text(
              'သင်တန်း အဓိက အချက်များ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            _buildFeaturesList(courseDetail.features),
            const SizedBox(height: kDefaultPadding * 2),

            // 3. Session ရွေးချယ်မှု ခေါင်းစဉ်
            const Text(
              'သင်တန်းရက်နှင့် အချိန်ရွေးချယ်ရန်',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: kDefaultPadding),

            // 4. Session ရွေးချယ်မှု UI 💡 Sessions FutureBuilder ကို ခေါ်သည်
            _buildSessionFutureBuilder(courseDetail),
            const SizedBox(height: kDefaultPadding * 2),

            // 5. အခုစာရင်းသွင်းရန် Button
            _buildEnrollButton(courseDetail.id, batchIdToPass),
          ],
        ),
      ),
    );
  }

  // 💡 Sessions Data ကို ကိုင်တွယ်မည့် FutureBuilder
  Widget _buildSessionFutureBuilder(CourseDetail courseDetail) {
    if (_sessionsFuture == null) {
      return const Center(
        child: Text(
          'လက်ရှိ Batch အတွက် Session အချက်အလက် မရှိသေးပါ။',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return FutureBuilder<List<CourseSession>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          );
        } else if (snapshot.hasError) {
          print('Sessions Error: ${snapshot.error}');
          return Center(
            child: Text(
              'Session Data ခေါ်ယူရာတွင် Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        } else if (snapshot.hasData) {
          return _buildSessionSelection(
            snapshot.data!,
            courseDetail.totalDurationHours,
          );
        }
        return const Center(
          child: Text(
            'သင်တန်း Session များ မရှိသေးပါ။',
            style: TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }

  // --- Header (ခေါင်းစဉ်) ---
  Widget _buildHeader(BuildContext context, CourseDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (detail.code.isNotEmpty)
          Text(
            'Code: ${detail.code}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
      ],
    );
  }

  // --- Course Description and Details ---
  Widget _buildCourseDescription(CourseDetail detail) {
    final String formattedPrice = _formatPrice(detail.priceValue);

    String durationText = '';
    if (detail.durationDays != null && detail.durationDays! > 0) {
      durationText += '${detail.durationDays} ရက်';
    }
    if (detail.totalDurationHours != null &&
        detail.totalDurationHours!.isNotEmpty) {
      if (durationText.isNotEmpty) durationText += ' | ';
      durationText += '${detail.totalDurationHours} နာရီ (စုစုပေါင်း)';
    }

    final cleanDescription = detail.description.replaceAll(
      RegExp(r'[\r\n]+'),
      '\n',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cleanDescription,
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        const SizedBox(height: kDefaultPadding * 1.5),

        // --- Price and Duration Row ---
        Wrap(
          spacing: kDefaultPadding,
          runSpacing: kDefaultPadding / 2,
          children: [
            if (formattedPrice.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.money, color: Colors.yellow, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'ဈေးနှုန်း: $formattedPrice',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (durationText.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    durationText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  // --- Features List (အသေးစိတ်များ) ---
  Widget _buildFeaturesList(List<String> features) {
    if (features.isEmpty) {
      return const Text(
        'ထူးခြားချက်များ ဖော်ပြထားခြင်း မရှိသေးပါ။',
        style: TextStyle(color: Colors.white70),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.cyanAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  feature,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 💡 Session Selection UI
  Widget _buildSessionSelection(
    List<CourseSession> sessions,
    String? totalDurationHours,
  ) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'သင်တန်း Session များ မရှိသေးပါ။',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final double requiredHours =
        double.tryParse(totalDurationHours ?? '0') ?? 0.0;
    final int selectedMinutes = sessions
        .where((s) => _selectedSessionIds.contains(s.id))
        .fold(0, (sum, item) => sum + item.durationMinutes);
    final double selectedHours = selectedMinutes / 60;

    String statusText;
    Color statusColor;
    if (requiredHours > 0 && selectedHours >= requiredHours) {
      statusText =
          'လိုအပ်သော Session အချိန် ပြည့်မှီပါပြီ။ (${selectedHours.toStringAsFixed(1)} / ${requiredHours.toStringAsFixed(1)} နာရီ)';
      statusColor = Colors.greenAccent;
    } else if (requiredHours > 0) {
      statusText =
          'Session အချိန် ရွေးချယ်ရန် လိုအပ်: ${selectedHours.toStringAsFixed(1)} / ${requiredHours.toStringAsFixed(1)} နာရီ';
      statusColor = Colors.orangeAccent;
    } else {
      statusText =
          'ရွေးချယ်ထားသော Sessions အရေအတွက်: ${_selectedSessionIds.length} ခု';
      statusColor = Colors.white70;
    }

    final Map<String, List<CourseSession>> groupedSessions = {};
    for (var session in sessions) {
      final date = session.formattedDate;
      groupedSessions.putIfAbsent(date, () => []).add(session);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // စုစုပေါင်းကြာချိန် Status Bar
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),

        // ရက်စွဲအလိုက် Session များ ပြသခြင်း
        ...groupedSessions.entries.map((entry) {
          final date = entry.key;
          final dailySessions = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: dailySessions.map((session) {
                  final isSelected = _selectedSessionIds.contains(session.id);
                  final bool isAvailable = session.status == 'available';

                  return ChoiceChip(
                    label: Text(session.formattedTime),
                    selected: isSelected,
                    onSelected: isAvailable
                        ? (selected) {
                            _toggleSessionSelection(session.id);
                          }
                        : null,
                    selectedColor: Colors.cyan.withOpacity(0.5),
                    backgroundColor: isAvailable
                        ? Colors.white12
                        : Colors.grey.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isAvailable
                          ? isSelected
                                ? Colors.white
                                : Colors.white70
                          : Colors.redAccent,
                      decoration: isAvailable
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // --- Enroll Button (အခုစာရင်းသွင်းပါ) ---
  Widget _buildEnrollButton(int courseId, int? batchId) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isBooking ? null : () => _handleEnroll(courseId, batchId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isBooking
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                'အခု စာရင်းသွင်းပါ',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
