// lib/screens/registration_screen.dart

import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/glass_card.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < kMobileBreakpoint;

    return Scaffold(
      // Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kGradientVia, kGradientEnd],
            stops: [0.1, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            _buildAppBar(), // Custom App Bar
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: SizedBox(
                    width: isMobile ? screenWidth * 0.9 : 400,
                    child: _buildRegistrationForm(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Registration Form UI ---
  Widget _buildRegistrationForm(BuildContext context) {
    return GlassCard(
      blurAmount: 10.0,
      opacity: 0.2,
      borderRadius: 15.0,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ခေါင်းစဉ်
            const Text(
              'အကောင့်ဖွင့်ပါ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: kDefaultPadding * 2),

            // Name Field
            _buildGlassTextField('အမည်အပြည့်အစုံ'),
            const SizedBox(height: kDefaultPadding),

            // Email Field
            _buildGlassTextField('အီးမေးလ်'),
            const SizedBox(height: kDefaultPadding),

            // Phone Number Field
            _buildGlassTextField('ဖုန်းနံပါတ်'),
            const SizedBox(height: kDefaultPadding),

            // Password Field
            _buildGlassTextField('စကားဝှက်', obscureText: true),
            const SizedBox(height: kDefaultPadding),

            // Confirm Password Field
            _buildGlassTextField('စကားဝှက် ထပ်မံအတည်ပြုပါ', obscureText: true),
            const SizedBox(height: kDefaultPadding * 2),

            // အကောင့်ဖွင့်ရန် Button
            _buildRegisterButton('အကောင့်ဖွင့်ရန်'),
            const SizedBox(height: kDefaultPadding * 2),

            // အကောင့်ရှိပြီးသားလား?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "အကောင့် ရှိပြီးသားလား?",
                  style: TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: () {
                    // Login Screen သို့ ပြန်သွားရန်
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ဝင်ရောက်ပါ',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Glass Text Field (Login Screen ကအတိုင်း ပြန်သုံးသည်) ---
  Widget _buildGlassTextField(String hintText, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // --- Register Button (Login Screen ကအတိုင်း ပြန်သုံးသည်) ---
  Widget _buildRegisterButton(String label) {
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- App Bar (Back Button ပါဝင်) ---
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        // Back Button ကို အလိုအလျောက် ထည့်ပေးပါမယ်
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Back Icon ကို အဖြူရောင်ပြောင်းရန်
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo Image ကို ဘောင်ကွေးထားသော ပုံစံ (အကယ်၍ Logo ပုံထည့်ထားပါက)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset('assets/amk.png', height: 35),
            ),
            const SizedBox(width: 8),
            const Text(
              'အကောင့်ဖွင့်ခြင်း',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
