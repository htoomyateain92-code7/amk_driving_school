import 'package:carapp/screens/instructor_dashboard_screen.dart';
import 'package:carapp/screens/student_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import 'owner_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isModal;

  const LoginScreen({super.key, this.isModal = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  bool _isLogin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- API Login Logic (Provider ဖြင့် ပြန်လည်ပြင်ဆင်) ---
  Future<void> _login() async {
    // 💡 Provider.of<ApiService>(context, listen: false) ကို ခေါ်ယူရန်
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'အမည်နှင့် လျှို့ဝှက်နံပါတ် ဖြည့်ရန် လိုအပ်ပါသည်။';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 💡 Login API Call ကို ခေါ်ယူသည်
      Map<String, dynamic> result = await apiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      // Login အောင်မြင်ပါက (Token ရရှိပြီး role ပြန်လာပါက)
      if (result['success'] == true && mounted) {
        // 💡 FIX: Role ပေါ်မူတည်၍ သက်ဆိုင်ရာ Dashboard သို့ တွန်းပို့ခြင်း
        String role = result['role']?.toLowerCase() ?? 'student';

        Widget destination;

        switch (role) {
          case 'owner':
            destination = const OwnerDashboardScreen();
            break;
          case 'instructor':
            destination = const InstructorDashboardScreen();
            break;
          case 'student':
          default:
            destination = const StudentDashboardScreen();
            break;
        }

        // 💡 Navigation: Dashboard သို့ Stack ရှင်းပြီး တွန်းပို့ခြင်း
        // isModal ဖြစ်စေ၊ မဖြစ်စေ၊ Login အောင်မြင်လျှင် Dashboard သို့ ရောက်ရမည်။
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => destination),
          (Route<dynamic> route) => false, // Stack ရှင်းလင်းခြင်း
        );

        return; // Login အောင်မြင်ပြီး Navigation လုပ်ပြီးနောက် ပြန်ထွက်မည်
      }
      // API မအောင်မြင်ရင်
      else if (mounted) {
        setState(() {
          _errorMessage =
              result['message'] ??
              'Login မအောင်မြင်ပါ: Server error သို့မဟုတ် ခွင့်ပြုချက်မရှိပါ။';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Login ပြဿနာ: API ချိတ်ဆက်မှု အမှား။ (Detail: ${e.toString()})';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isModal
          ? AppBar(
              title: const Text('အကောင့်ဝင်ရန်'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,

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
            padding: const EdgeInsets.all(kDefaultPadding * 2),
            child: GlassCard(
              blurAmount: 15.0,
              borderRadius: 20.0,

              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _isLogin ? 'အကောင့်ဝင်ရန်' : 'အကောင့်အသစ်ဖွင့်ရန်',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      _usernameController,
                      'အမည်/ဖုန်းနံပါတ်',
                      Icons.person,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _passwordController,
                      'လျှို့ဝှက်နံပါတ်',
                      Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),

                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),

                    _buildGradientButton(
                      _isLogin ? 'ဝင်ရောက်ပါ' : 'မှတ်ပုံတင်ပါ',
                      // 💡 onPressed တွင် _login function ကို ထည့်သွင်းထားသည်
                      _isLogin
                          ? _login
                          : () {
                              // Register Functionality Needed
                              print('Register Functionality Needed');
                            },
                    ),

                    const SizedBox(height: 20),

                    // Register/Login Switcher Button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = '';
                          _usernameController.clear();
                          _passwordController.clear();
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'အကောင့်မရှိသေးဘူးလား? အကောင့်ဖွင့်ပါ'
                            : 'အကောင့်ရှိပြီးသားလား? ဝင်ရောက်ပါ',
                        style: TextStyle(
                          color: Colors.cyanAccent.withOpacity(0.8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable Text Field ---
  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    // ... (Text Field implementation)
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Glassmorphism input field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
      ),
    );
  }

  // --- Gradient Button ---
  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    // ... (Button implementation)
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [kGradientVia, kGradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kGradientEnd.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
