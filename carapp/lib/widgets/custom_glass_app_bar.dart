// lib/widgets/custom_glass_app_bar.dart (Fixed Gradient Header - Glassmorphism Removed)

import 'package:flutter/material.dart';
import '../constants/constants.dart'; // Gradient Colors များအတွက်

class CustomGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final String selectedLanguage;
  final ValueChanged<String?> onLanguageChanged;
  final Widget loginButton;

  const CustomGlassAppBar({
    super.key,
    this.title,
    this.actions,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.loginButton,
    required IconButton leading,
  });

  // ပုံထဲက Header ရဲ့ အနက်ပိုင်း အရောင်ကို Gradient ကနေ ယူပါ
  final Color fixedHeaderColor = const Color(0xFF312E81); // kGradientStart

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // 💡 BackdropFilter နှင့် ClipRect များကို ဖယ်ရှားလိုက်ပါပြီ

    return Container(
      // 💡 ပုံထဲက Header ရဲ့ အနက်/ခရမ်း အရောင်ကို Gradient ဖြင့် သတ်မှတ်ပါ
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Gradient Start/End ကို App Bar အတွက် နည်းနည်း ချိန်ညှိပါ
          colors: [kGradientStart, kGradientStart.withOpacity(0.9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        // ပုံထဲကအတိုင်း အောက်ခြေမှာ ခပ်ပါးပါး Border ပါးလေးထားပါ
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 2.0),
        ),
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        title: title,
        actions: [
          // 1. ဘာသာစကား ရွေးချယ်မှု (ပုံထဲမှာ မြန်မာအလံနဲ့ Dropdown ပါ)
          _buildLanguageSelector(),

          // 2. Notification Icon (ပုံထဲကအတိုင်း)
          _buildNotificationIcon(),

          const SizedBox(width: 8),

          // 3. Login Button (Gradient Box ထဲထည့်ထားတဲ့ Button)
          loginButton,

          const SizedBox(width: kDefaultPadding / 2),
        ],
        // 💡 AppBar Background ကို Transparent ထားပြီး Container ရဲ့ Gradient ကို ပြပါ
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  // --- _buildLanguageSelector Method ---
  Widget _buildLanguageSelector() {
    // 💡 ပုံထဲမှာ မြန်မာအလံနဲ့ 'မြန်မာ' စာသားသာ ပေါ်နေပါတယ်။ Notification ကို ဖယ်ပြီး အလံကိုပဲ ထားပါမယ်။
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          const Text('🇲🇲', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 4),
          Text(
            selectedLanguage == 'MM' ? 'မြန်မာ' : 'English',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          // Dropdown Icon ကို ဖယ်ထားပါမယ်။
        ],
      ),
    );
  }

  // --- _buildNotificationIcon Method ---
  Widget _buildNotificationIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          // 💡 Notification Icon ကို ရိုးရိုး Icon အဖြစ် ပြန်ထားပါမယ်။
          const Icon(Icons.notifications_none, color: Colors.white, size: 24),
          // Red Dot
          Positioned(
            right: 0,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
