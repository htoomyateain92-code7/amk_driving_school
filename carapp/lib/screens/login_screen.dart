// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import 'owner_dashboard_screen.dart'; // ဝင်ရောက်ပြီးနောက် သွားမည့် Dashboard (ဥပမာ)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';

  // 💡 နောက်မှ Register/Login ကို ခွဲခြားရန် (ပုံမှန်အားဖြင့် Tab သုံးသည်)
  bool _isLogin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- API Login Logic ---
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 💡 ApiService မှ Login Function ကို ခေါ်ယူသည်
      String token = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      // Login အောင်မြင်ပါက (Token ရရှိပါက)
      // ဥပမာ- Token ကို SharedPreferences တွင် သိမ်းဆည်းပြီး Dashboard သို့ သွားပါ
      if (mounted) {
        // [TODO]: Token သိမ်းဆည်းရန် Logic

        // 💡 ယာယီအားဖြင့် Owner Dashboard သို့ သွားပါ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login Failed: Invalid credentials or API error.';
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
      appBar: AppBar(
        title: const Text('Login / Register'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding * 2),
            child: GlassCard(
              blurAmount: 15.0, // Form Card ကို ပိုမိုမှုန်ဝါးစေပါ
              borderRadius: 20.0,
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _isLogin ? 'အကောင့်ဝင်ရန်' : 'အကောင့်အသစ်ဖွင့်ရန်',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      _usernameController,
                      'အမည်/အီးမေးလ်',
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
                      _login,
                    ),

                    const SizedBox(height: 20),

                    // Register/Login Switcher Button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = '';
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
