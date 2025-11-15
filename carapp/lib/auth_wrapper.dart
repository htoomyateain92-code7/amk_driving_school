import 'package:carapp/screens/course_selection_screen.dart';
import 'package:carapp/screens/dashboard_screen.dart';
import 'package:carapp/screens/home_screen.dart';
import 'package:carapp/screens/instructor_dashboard_screen.dart';
import 'package:carapp/screens/owner_dashboard_screen.dart';
import 'package:carapp/screens/student_dashboard_screen.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 💡 ၎င်းတို့ကို သင့်တော်သလို Import လုပ်ပါ

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 [FIXED]: Provider မှ userRole ကို တိုက်ရိုက်နားထောင်ခြင်း (context.watch)
    final userRole = context.watch<ApiService>().userRole;

    // ၁. Initialization စစ်ဆေးနေဆဲ
    if (userRole == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.indigo),
              SizedBox(height: 10),
              Text('စစ်ဆေးနေသည်...', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      );
    }

    // ၂. Role အလိုက် Navigation လုပ်ခြင်း
    switch (userRole) {
      case 'owner':
        // 💡 [FIXED]: DashboardScreen constructor မှာ role parameter မလိုအပ်ပါ။
        // OwnerDashboardScreen သည် role ကို Provider ကနေ တိုက်ရိုက်ဖတ်ပါမည်။
        return const OwnerDashboardScreen();
      case 'instructor':
        // 💡 [FIXED]: DashboardScreen constructor မှာ role parameter မလိုအပ်ပါ။
        return const InstructorDashboardScreen();
      case 'student':
        // 💡 [FIXED]: DashboardScreen constructor မှာ role parameter မလိုအပ်ပါ။
        return const StudentDashboardScreen();
      case 'guest':
      default:
        // Login မဝင်ရသေး သို့မဟုတ် Role မသိပါက Home (Login) Screen ကို ပြပါမည်။
        return const HomeScreen();
    }
  }
}
