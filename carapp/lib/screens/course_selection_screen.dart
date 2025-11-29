import 'package:carapp/models/course_model.dart';
import 'package:carapp/screens/blog_detail_screen.dart';
import 'package:carapp/screens/course_detail_screen.dart';
import 'package:carapp/screens/login_screen.dart';
import 'package:carapp/screens/quiz_detail_screen.dart';
import 'package:carapp/screens/student_dashboard_screen.dart';
import 'package:carapp/services/api_service.dart';
import 'package:carapp/widgets/course_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  late ApiService _apiService;

  // 💡 API Data များကို စုစည်းထားသည့် Future
  Future<Map<String, dynamic>>? _dataFuture;

  // 💡 Data Structure: {'courses': List<Map>, 'quizzes': List<Map>, 'blogs': List<Map>}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _apiService = Provider.of<ApiService>(context);
    // 💡 Data Future ကို စတင် Load လုပ်သည်
    if (_dataFuture == null) {
      _dataFuture = _fetchData() as Future<Map<String, dynamic>>?;
    }
  }

  // 💡 API မှ Course, Quiz, Blog Data များ တစ်ပြိုင်နက် ခေါ်ယူရန် Function
  Future<Map<String, dynamic>> _fetchData() async {
    // Public Page ဖြစ်သောကြောင့် isPublic: true ပို့ရန်
    const bool isPublic = true;

    // 💡 Future.wait ကို အသုံးပြု၍ API Call များကို တစ်ပြိုင်နက် ခေါ်ယူသည်
    final results = await Future.wait([
      _apiService.fetchCourses(isPublic: isPublic),
      _apiService.fetchQuizzes(),
      _apiService.fetchBlogs(),
    ]);

    // results [0] = Courses, [1] = Quizzes, [2] = Blogs
    return {'courses': results[0], 'quizzes': results[1], 'blogs': results[2]};
  }

  // 💡 Navigation Functions (ယခင်အတိုင်းရှိနေသည်)
  void _navigateToDashboard() {
    if (_apiService.isLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const StudentDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard ကို သွားရန် အကောင့်ဝင်ရန် လိုအပ်ပါသည်။'),
        ),
      );
    }
  }

  // 💡 Login/Logout Button ကို သွားမည့် function (Auth Screen)
  void _navigateToAuthScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    // print('Navigate to Login/Signup Screen');
  }

  // 💡 သင်တန်း စာရင်းသွင်းရန် (သို့) အသေးစိတ်ကြည့်ရန် Function
  void _navigateToCourseDetail(String courseTitle, int courseId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            // 🛑 [FIX]: CourseDetailScreen ၏ Constructor ကို စစ်ဆေးပါ။
            // title: '' ပို့ခြင်းသည် Error ကို ဖြေရှင်းပေးသော်လည်း အသုံးမဝင်ပါ။
            // ယခု title: courseTitle ကို ပို့လိုက်ပါမည်။
            CourseDetailScreen(courseId: courseId, title: courseTitle),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$courseTitle အတွက် စာရင်းသွင်းရန် စာမျက်နှာကို သွားပါမည်။ (ID: $courseId)',
        ),
      ),
    );
  }

  // 💡 Quiz Detail Screen သို့ သွားရန် Function
  void _navigateToQuizDetail(String quizTitle, int quizId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizDetailScreen(
          quizId: quizId,
          quizTitle: quizTitle,
          // title ကို မလိုအပ်ပါက ဖယ်နိုင်သည်၊ လိုအပ်ပါက quizTitle ကို ပေးနိုင်သည်။
          title: quizTitle,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$quizTitle စာမေးပွဲ စတင်ဖြေဆိုရန် စာမျက်နှာကို သွားပါမည်။ (ID: $quizId)',
        ),
      ),
    );
  }

  // 💡 Blog Detail Screen သို့ သွားရန် Function
  void _navigateToBlogDetail(String blogTitle, int blogId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlogDetailScreen(
          title: blogTitle, // ✅ title parameter ကို blogTitle ဖြင့် ပေးပို့သည်
          blogId: blogId,
          // 🛑 [FIX]: blogTitle parameter ကို ထပ်မံပေးပို့ရန် မလိုတော့ပါ
          // blogTitle: 'title', // ဤလိုင်းကို ဖယ်လိုက်ပါ
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$blogTitle အကြောင်းအရာကို အသေးစိတ် ကြည့်ရှုပါမည်။ (ID: $blogId)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = _apiService.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('သင်တန်းများ (Courses)'),
        backgroundColor: kGradientStart,
        elevation: 0,
        actions: [
          // ... (App Bar Actions Code - မပြောင်းလဲပါ) ...
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              /* Handle Notifications */
            },
            color: Colors.white,
          ),
          if (isLoggedIn)
            GestureDetector(
              onTap: _navigateToDashboard,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'student',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            TextButton(
              onPressed: _navigateToAuthScreen,
              child: const Text(
                'ဝင်/အကောင့်ဖွင့်မည်',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kGradientVia, kGradientEnd],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // 💡 [FIX]: FutureBuilder ကို အသုံးပြု၍ API Data ကို ပြသခြင်း
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Data ခေါ်ယူရာတွင် အမှား: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              // API မှရလာသော List များကို ထုတ်ယူခြင်း
              final List courses = data['courses'] ?? [];
              final List quizzes = data['quizzes'] ?? [];
              final List blogs = data['blogs'] ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
                      child: Text(
                        'သင်မောင်းနှင်မည့် ခရီးလမ်းအတွက် အသင့်ပြင်ပါ!!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // --- Courses Section (Dynamic) ---
                    if (courses.isNotEmpty)
                      ...courses.map((courseItem) {
                        final Course course = courseItem as Course;
                        // 💡 API Data ဖြင့် _buildCourseCard ကို ခေါ်ဆိုခြင်း
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: kDefaultPadding,
                          ),
                          child: _buildCourseCard(
                            title: course.title ?? '', // ✅ Dot Notation
                            price: course.price ?? '', // ✅ Dot Notation
                            description:
                                course.description ?? '', // ✅ Dot Notation
                            color: Color(course.color), // ✅ Dot Notation
                            courseId: course.id, // ✅ Dot Notation
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: kDefaultPadding * 2),

                    // --- Quizzes Section (Dynamic) ---
                    if (quizzes.isNotEmpty)
                      _buildSectionHeader('Quiz စစ်မေးခွန်းများ (Quizzes)'),
                    if (quizzes.isNotEmpty)
                      ...quizzes.map((quiz) {
                        // 💡 API Data ဖြင့် _buildQuizItem ကို ခေါ်ဆိုခြင်း
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildQuizItem(
                            quiz.title ?? '',
                            quizId: quiz.id,
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: kDefaultPadding * 2),

                    // --- Blogs Section (Dynamic) ---
                    // if (blogs.isNotEmpty)
                    //   _buildSectionHeader('Blog များ (Blogs)'),
                    // if (blogs.isNotEmpty)
                    //   ...blogs.map((blog) {
                    //     // 💡 API Data ဖြင့် _buildBlogItem ကို ခေါ်ဆိုခြင်း
                    //     return Padding(
                    //       padding: const EdgeInsets.only(bottom: 8.0),
                    //       child: _buildBlogItem(
                    //         blog.title ?? '',
                    //         blogId: blog.id,
                    //       ),
                    //     );
                    //   }).toList(),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'Data မရှိပါ',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // --- Utility Widgets (မပြောင်းလဲပါ) ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding / 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String price,
    required String description,
    required Color color,
    required int courseId,
  }) {
    // ... (UI Code သည် ယခင်အတိုင်း မှန်ကန်နေပါသည်) ...
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              price,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                _navigateToCourseDetail(title, courseId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'စာရင်းသွင်းမည်',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizItem(String title, {required int quizId}) {
    // ... (UI Code သည် ယခင်အတိုင်း မှန်ကန်နေပါသည်) ...
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: () {
          _navigateToQuizDetail(title, quizId);
        },
      ),
    );
  }

  Widget _buildBlogItem(String title, {required int blogId}) {
    // ... (UI Code သည် ယခင်အတိုင်း မှန်ကန်နေပါသည်) ...
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Text(
          'ကြည့်ရန်',
          style: TextStyle(color: Colors.cyanAccent),
        ),
        onTap: () {
          _navigateToBlogDetail(title, blogId);
        },
      ),
    );
  }
}
