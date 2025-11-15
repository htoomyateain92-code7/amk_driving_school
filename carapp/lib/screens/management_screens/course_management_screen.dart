import 'package:carapp/models/course_model.dart';
import 'package:carapp/screens/course_detail_screen.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../widgets/custom_glass_app_bar.dart';
import '../../widgets/glass_card.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Course>> _courseListFuture;

  @override
  void initState() {
    super.initState();
    // READ: Dashboard အတွက် Private Courses အားလုံးကို ယူရန်
    _courseListFuture = _apiService.fetchCourses(isPublic: false);
  }

  // စျေးနှုန်းကို Format လုပ်ရန် Helper Method
  String _formatPrice(dynamic priceValue) {
    if (priceValue == null) return 'အခမဲ့';

    double? price;

    if (priceValue is String) {
      price = double.tryParse(priceValue);
    } else if (priceValue is double) {
      price = priceValue;
    } else if (priceValue is int) {
      price = priceValue.toDouble();
    }

    if (price == null || price == 0) return 'အခမဲ့';

    // MMK အတွက် Comma ခွဲပြီး decimal မပါဘဲ ပြသပါ
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(price);
  }

  // READ: Course List ကို ပြန်လည်ခေါ်ယူခြင်း
  void _refreshCourseList() {
    setState(() {
      _courseListFuture = _apiService.fetchCourses(isPublic: false);
    });
  }

  // CREATE/UPDATE: Form Screen သို့ သွားခြင်း
  void _navigateToCourseDetail({Course? course}) async {
    final int courseId = course?.id ?? 0;
    final String screenTitle = course == null
        ? 'သင်တန်းအသစ် ဖန်တန်းရန်'
        : 'သင်တန်းပြင်ဆင်ရန်';

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            // courseId 0 ဆိုရင် Create, >0 ဆိုရင် Update အတွက် Data Load မည်
            CourseDetailScreen(title: screenTitle, courseId: courseId),
      ),
    );

    // CRUD လုပ်ဆောင်ချက် အောင်မြင်ပါက (result == true) List ကို Refresh လုပ်ခြင်း
    if (result == true) {
      _refreshCourseList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              course == null
                  ? 'သင်တန်းအသစ် ဖန်တီးခြင်း အောင်မြင်ပါသည်။'
                  : 'သင်တန်း ID ${course!.id} ပြင်ဆင်ခြင်း အောင်မြင်ပါသည်။',
            ),
          ),
        );
      }
    } else if (result == false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('လုပ်ဆောင်ချက် ဖျက်သိမ်းလိုက်ပါသည်။')),
      );
    }
  }

  // DELETE: Course ကို ဖျက်ရန် Logic
  void _deleteCourse(int id, String title) async {
    try {
      await _apiService.deleteCourse(id);
      _refreshCourseList(); // ဖျက်ပြီးနောက် List ကို Update လုပ်မည်

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('သင်တန်း "$title" ဖျက်ခြင်း အောင်မြင်ပါသည်။')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course ဖျက်ခြင်း မအောင်မြင်ပါ: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGlassAppBar(
        selectedLanguage: 'MM',
        onLanguageChanged: (value) {},
        title: const Text('သင်တန်းများ စီမံခန့်ခွဲရန်'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Refresh Button
        loginButton: TextButton.icon(
          onPressed: _refreshCourseList,
          icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
          label: const Text('Refresh', style: TextStyle(color: Colors.white)),
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
        child: Column(
          children: [
            // --- CREATE: Add New Button ---
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCourseDetail(),
                icon: const Icon(Icons.add_circle, color: Colors.black),
                label: const Text(
                  'သင်တန်းအသစ် ဖန်တီးရန်',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            // --- READ: Course List Section ---
            Expanded(
              child: FutureBuilder<List<Course>>(
                future: _courseListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Text(
                          'သင်တန်းစာရင်း ခေါ်ယူရာတွင် Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final course = snapshot.data![index];
                        return _buildCourseCard(course);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'သင်တန်းများ မရှိသေးပါ',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Course Card ၏ UI (Read Item & Action Buttons) ---
  Widget _buildCourseCard(Course course) {
    final isPublished = course.isPublished ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: GlassCard(
        blurAmount: 5.0,
        borderRadius: 10.0,
        borderWidth: 0.5,
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              // Status Indicator
              Icon(
                isPublished ? Icons.check_circle : Icons.pending,
                color: isPublished
                    ? Colors.lightGreenAccent
                    : Colors.orangeAccent,
                size: 30,
              ),
              const SizedBox(width: kDefaultPadding),

              // Title and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title ?? 'အမည်မသိ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Price: ${_formatPrice(course.price)} MMK | Students: ${course.studentCount ?? 0}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // UPDATE Button
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                onPressed: () => _navigateToCourseDetail(course: course),
              ),
              // DELETE Button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirmation(
                  course.id,
                  course.title ?? 'အမည်မသိ',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DELETE Confirmation Dialog ---
  void _showDeleteConfirmation(int id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ဖျက်ရန် အတည်ပြုပါ'),
        content: Text('သင်တန်း "$title" (ID: $id) ကို သေချာဖျက်မှာလား?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('မဖျက်တော့ပါ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialog ကို ပိတ်ပါ
              _deleteCourse(id, title); // Delete Function ကို ခေါ်မည်
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ဖျက်မည်', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
