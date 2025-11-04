// lib/screens/course_detail_screen.dart

import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/glass_card.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen Width ပေါ်မူတည်ပြီး Content ရဲ့ အကျယ်ကို တွက်ချက်ပါ
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < kMobileBreakpoint;

    return Scaffold(
      // Gradient Background
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
              // Content Area ကို စကရင်အကျယ်ပေါ်မူတည်ပြီး ကန့်သတ်ပါ
              width: isMobile ? screenWidth * 0.95 : 700,
              child: _buildDetailCard(context),
            ),
          ),
        ),
      ),
    );
  }

  // --- Course Detail Card UI ---
  Widget _buildDetailCard(BuildContext context) {
    return GlassCard(
      blurAmount: 15.0, // Blur ပိုများပါမည်
      opacity: 0.25, // ပုံထဲကအတိုင်း နည်းနည်း ပိုပြတ်သားစေရန်
      borderRadius: 20.0, // ပုံထဲကအတိုင်း ပိုကွေးစေရန်
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 1. ခေါင်းစဉ်နှင့် Close Button
            _buildHeader(context),
            const SizedBox(height: kDefaultPadding * 1.5),

            // 2. သင်တန်းအသေးစိတ် ဖော်ပြချက်
            _buildCourseDescription(),
            const SizedBox(height: kDefaultPadding * 2),

            // 3. အတန်းဖော်ချိန်ဇယား ခေါင်းစဉ်
            const Text(
              'အတန်းဖော်ချိန်ဇယား',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: kDefaultPadding),

            // 4. အပတ်စဉ် အချိန်ဇယား
            _buildScheduleGrid(),
            const SizedBox(height: kDefaultPadding * 2),

            // 5. အခုစာရင်းသွင်းရန် Button
            _buildEnrollButton(),
          ],
        ),
      ),
    );
  }

  // --- Header (ခေါင်းစဉ်နှင့် Close Button) ---
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'အခြေခံ ကားမောင်းသင်တန်း', // သင်တန်းခေါင်းစဉ်
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(
              context,
            ); // ဒီ Screen ကို ပိတ်ပြီး အရင် Screen သို့ ပြန်သွားရန်
          },
        ),
      ],
    );
  }

  // --- Course Description and Details ---
  Widget _buildCourseDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ကားမောင်းခြင်း၏ အခြေခံ နည်းပြောင်းလဲခြင်း၊ ရပ်တန့်ခြင်းနှင့် လမ်းစည်းကမ်းများ အကျုံးဝင်သော သင်တန်းဖြစ်ပါသည်။ အသေးစိတ် စာရွက်စာတမ်းများ အတွက် အခုပဲ သွင်းလိုက်ပါ။',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        const SizedBox(height: kDefaultPadding),
        Row(
          children: const [
            Icon(Icons.access_time, color: Colors.yellow, size: 18),
            SizedBox(width: 4),
            Text(
              'ကြာမြင့်ချိန်: ၁၀ ရက်', //
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: kDefaultPadding),
            Icon(Icons.money, color: Colors.yellow, size: 18),
            SizedBox(width: 4),
            Text(
              'ဈေးနှုန်း: ၅၀၀,၀၀၀ ကျပ်', //
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Schedule Grid ---
  Widget _buildScheduleGrid() {
    // ပုံထဲကအတိုင်း နေ့ရက်များနှင့် အခြေအနေများ
    final List<Map<String, dynamic>> schedule = [
      {'day': 'တနင်္လာ', 'time': 'မနက် ၉:၀၀ - ၁၁:၀၀', 'status': 'ဖွင့်လှစ်'},
      {'day': 'အင်္ဂါ', 'time': 'အားလပ်သည်', 'status': 'ပိတ်ထားသည်'},
      {'day': 'ဗုဒ္ဓဟူး', 'time': 'နေ့လယ် ၃:၀၀ - ၅:၀၀', 'status': 'ဖွင့်လှစ်'},
      {'day': 'ကြာသပတေး', 'time': 'အားလပ်သည်', 'status': 'ပိတ်ထားသည်'},
      {'day': 'သောကြာ', 'time': 'မနက် ၉:၀၀ - ၁၁:၀၀', 'status': 'ဖွင့်လှစ်'},
      {'day': 'စနေ', 'time': 'အားလပ်သည်', 'status': 'ပိတ်ထားသည်'},
      {'day': 'တနင်္ဂနွေ', 'time': 'အားလပ်သည်', 'status': 'ပိတ်ထားသည်'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // တစ်တန်းမှာ ၃ ခုပြရန်
        crossAxisSpacing: kDefaultPadding,
        mainAxisSpacing: kDefaultPadding,
        childAspectRatio: 1.5, // Card ရဲ့ အချိုး
      ),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final item = schedule[index];
        return _buildScheduleItem(
          item['day']!,
          item['time']!,
          item['status']! == 'ဖွင့်လှစ်',
        );
      },
    );
  }

  // --- Schedule Item Card ---
  Widget _buildScheduleItem(String day, String time, bool isOpen) {
    return GlassCard(
      blurAmount: 5.0,
      opacity: 0.1,
      borderRadius: 10.0,
      borderColor: Colors.transparent, // Border မပါ
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isOpen ? Colors.white : Colors.white54,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: isOpen ? Colors.cyanAccent : Colors.white38,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- Enroll Button (Login Button ကအတိုင်း Gradient ပုံစံ) ---
  Widget _buildEnrollButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // အပြာခရမ်း Gradient
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
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
