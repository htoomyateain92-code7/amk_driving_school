// lib/screens/course_selection_screen.dart (Updated)

import 'package:carapp/screens/course_detail_screen.dart';
import 'package:carapp/screens/login_screen.dart';
import 'package:carapp/widgets/custom_glass_app_bar.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/course_item.dart';
import '../widgets/section_card.dart';

// StatefulWidget အဖြစ် ပြောင်းလဲပါ
class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  // ရွေးချယ်ထားသော ဘာသာစကား (စတင်ချိန်မှာ မြန်မာကို ရွေးထားသည်)
  String _selectedLanguage = 'MM'; // 'MM' for Myanmar, 'EN' for English

  @override
  Widget build(BuildContext context) {
    final String loginButtonText = _selectedLanguage == 'MM'
        ? 'ဝင်/အကောင့်ဖွင့်'
        : 'Login / Register';

    final Widget customLoginButton = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // ဘောင်ကွေးခြင်း
        gradient: LinearGradient(
          // ပုံထဲကလို Gradient Background
          colors: [
            kGradientVia.withOpacity(0.8),
            kGradientEnd.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kGradientEnd.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 18),
        label: Text(
          loginButtonText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent, // Background ကို ပွင့်လင်းထား
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: CustomGlassAppBar(
        selectedLanguage: _selectedLanguage,
        onLanguageChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLanguage = newValue;
              print('Language changed to: $_selectedLanguage');
            });
          }
        },
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 💡 ပုံထဲက Logo အသေးစားကို ဒီနေရာမှာ ထားပါ
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/amk.png',
                width: 100,
                height: 50,
              ), // အရောင်ပြောင်းထားသော Logo သို့မဟုတ် Icon
            ),
            const SizedBox(width: 10),

            // 💡 App Title (ကားသင်တန်း ကျောင်း)
          ],
        ),
        actions: [
          // 💡 Login/Logout Button ကို actions အဖြစ် ပို့ပေးပါ
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
            label: Text(
              loginButtonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
        loginButton: customLoginButton,
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
        child: CustomScrollView(
          slivers: <Widget>[
            // 1. App Bar (SliverAppBar) ကို ပြင်ဆင်ပါ
            // _buildAppBar(), // App Bar ကို Method အသစ်နဲ့ ခေါ်ပါမည်
            SliverPadding(
              padding: const EdgeInsets.all(kDefaultPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ... (ကျန်တဲ့ UI အစိတ်အပိုင်းတွေ ဒီအတိုင်းထားပါ)
                  _buildBanner(),
                  const SizedBox(height: kDefaultPadding * 2),
                  _buildCoursesSection(),
                  const SizedBox(height: kDefaultPadding * 2),
                  _buildQuizAndBlogSection(context),
                  const SizedBox(height: kDefaultPadding * 4),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- App Bar Widget (Language Selector ထည့်သွင်းထားသည်) ---

  // --- Language Selector Widget ---
  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          dropdownColor: kGradientStart.withOpacity(
            0.9,
          ), // Glass Card အရောင်နဲ့ နီးစပ်အောင်
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLanguage = newValue;
                // ဘာသာစကား ပြောင်းလဲမှု Logic ကို ဒီနေရာမှာ ထည့်နိုင်ပါတယ်
                print('Language changed to: $_selectedLanguage');
              });
            }
          },
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: 'MM',
              child: Row(
                children: const [
                  Text('🇲🇲', style: TextStyle(fontSize: 20)), // မြန်မာအလံ
                  SizedBox(width: 8),
                  Text('မြန်မာ', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'EN',
              child: Row(
                children: const [
                  Text(
                    '🇺🇸',
                    style: TextStyle(fontSize: 20),
                  ), // အမေရိကန်အလံ (အင်္ဂလိပ်ဘာသာအတွက်)
                  SizedBox(width: 8),
                  Text('English', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Courses Section (Responsive Grid)
  Widget _buildCoursesSection() {
    // 💡 ပြဿနာ (၁) ဖြေရှင်းရန်: Data Structure ကို Map<String, dynamic> ပြောင်းပြီး Localization Data ထည့်ပါ။
    final List<Map<String, dynamic>> courses = [
      {
        'duration': {'MM': '၁၀ ရက်', 'EN': '10 days'},
        'price': {'MM': '၅၀၀,၀၀၀ ကျပ်', 'EN': '500,000MMKs'},
        // 💡 Localization Data ထည့်ခြင်း
        'title': {
          'MM': 'အခြေခံ ကားမောင်းသင်တန်း',
          'EN': 'Basic Driving Course',
        },
        'button': {'MM': 'စာရင်းသွင်းရန်', 'EN': 'Enroll Now'},
      },
      {
        'duration': {'MM': '၈ ရက်', 'EN': '8 days'},
        'price': {'MM': '၈၀၀,၀၀၀ ကျပ်', 'EN': '800,000MMKs'},
        'title': {
          'MM': 'အဆင့်မြင့် မော်တော်ယာဉ်',
          'EN': 'Advanced Vehicle Training',
        },
        'button': {'MM': 'စာရင်းသွင်းရန်', 'EN': 'Enroll Now'},
      },
      {
        'duration': {'MM': '၅ ရက်', 'EN': '5 days'},
        'price': {'MM': '၃၀၀,၀၀၀ ကျပ်', 'EN': '300,000MMKs'},
        'title': {
          'MM': 'ယာဉ်စည်းကမ်း လမ်းစည်းကမ်း',
          'EN': 'Traffic Rules & Regulations',
        },
        'button': {'MM': 'စာရင်းသွင်းရန်', 'EN': 'Enroll Now'},
      },
    ];

    // MM/EN ပေါ်မူတည်ပြီး ခေါင်းစဉ် ပြောင်းရန် (ဒါက အလုပ်လုပ်ပြီးသားပါ)
    final String sectionTitle = _selectedLanguage == 'MM'
        ? 'သင်တန်းများ (Courses)'
        : 'Courses';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: kDefaultPadding),

        LayoutBuilder(
          builder: (context, constraints) {
            final int crossAxisCount = constraints.maxWidth >= 900
                ? 3
                : (constraints.maxWidth > kMobileBreakpoint ? 2 : 1);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: kDefaultPadding,
                mainAxisSpacing: kDefaultPadding,
                childAspectRatio: 1.5,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CourseDetailScreen(),
                      ),
                    );
                  },
                  child: CourseItem(
                    // 💡 ပြဿနာ (၂) ဖြေရှင်းရန်: Localization Logic ဖြင့် တန်ဖိုးများကို ဆွဲထုတ်ခြင်း
                    title: course['title'][_selectedLanguage]!,
                    duration: course['duration'][_selectedLanguage]!,
                    price: course['price'][_selectedLanguage]!,
                    buttonText:
                        course['button'][_selectedLanguage]!, // buttonText လည်း Localization လုပ်ပါ
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // --- Banner/Header Widget ---
  Widget _buildBanner() {
    final String bannerText = _selectedLanguage == 'MM'
        ? '🚗 သင်မောင်းနှင်ရမည့် ခရီးလမ်းအတွက် အသင့်ပြင်ပါ!!'
        : '🚗 Get Ready for Your Driving Journey!!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bannerText,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // --- Quiz & Blog Sections (Responsive) ---
  Widget _buildQuizAndBlogSection(BuildContext context) {
    // MM/EN ပေါ်မူတည်ပြီး ခေါင်းစဉ်များနှင့် စာသားများ ပြောင်းလဲရန် Logic
    final String quizTitle = _selectedLanguage == 'MM'
        ? 'Quiz စစ်မေးခွန်းများ (Quizzes)'
        : 'Quiz Questions (Quizzes)';
    final String blogTitle = _selectedLanguage == 'MM'
        ? 'Blog များ (Blogs)'
        : 'Blog Posts (Blogs)';

    // Quiz Card အတွင်းက Items (Text များကို _selectedLanguage ဖြင့် စစ်ဆေးပါ)
    final List<Widget> quizItems = [
      SectionItem(
        text: _selectedLanguage == 'MM'
            ? 'ယာဉ်မောင်းလက်မှတ် စစ်မေးခွန်းများ'
            : 'Driving License Exam Questions',
      ),
      SectionItem(
        text: _selectedLanguage == 'MM'
            ? 'အရေးပေါ် အခြေအနေ စစ်မေးခွန်းများ'
            : 'Emergency Scenario Questions',
      ),
      SectionItem(
        text: _selectedLanguage == 'MM'
            ? 'ယာဉ်စည်းကမ်းဆိုင်ရာ အမှတ်တရ Quiz'
            : 'Traffic Rules Quiz',
      ),
    ];

    // Blog Card အတွင်းက Items
    final List<Widget> blogItems = [
      SectionItem(
        text: _selectedLanguage == 'MM'
            ? '၂၀၂၅ ယာဉ်မောင်းလိုင်စင် စည်းမျဉ်းများ'
            : '2025 Driving License Regulations',
        date: _selectedLanguage == 'MM' ? 'ဇွန်လ ၂၀ ရက်' : 'Jun 20',
      ),
      SectionItem(
        text: _selectedLanguage == 'MM'
            ? 'ကားစ်ခေါင်ခြင်း အခြေခံနည်းလမ်း ၅ ချက်'
            : '5 Basic Car Maintenance Tips',
        date: _selectedLanguage == 'MM' ? 'ဇွန်လ ၅ ရက်' : 'Jun 5',
      ),
      SectionItem(
        text: _selectedLanguage == 'MM' ? 'အားလုံးကြည့်ရန်' : 'View All',
      ),
    ];

    // ... (Layout Logic ကို ဒီအတိုင်းထားပါ)
    return MediaQuery.of(context).size.width < 900
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionCard(title: quizTitle, items: quizItems),
              const SizedBox(height: kDefaultPadding),
              SectionCard(title: blogTitle, items: blogItems),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionCard(title: quizTitle, items: quizItems),
              ),
              const SizedBox(width: kDefaultPadding),
              Expanded(
                child: SectionCard(title: blogTitle, items: blogItems),
              ),
            ],
          );
  }
}
