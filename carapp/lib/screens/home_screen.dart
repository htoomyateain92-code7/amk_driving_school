import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 💡 Provider ကို သုံးရန်
import '../constants/constants.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import 'course_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  // 💡 HomeScreen မှာ isModal မလိုအပ်ပါ (LoginScreen မှသာ လိုအပ်သည်)
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // 💡 Register အတွက် Confirm Password Controller (သင်၏ ယခင် code အတိုင်း ထည့်ပေးထားသည်)
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- API Login Logic (Provider-based) ---
  // 🎯 Provider/context.read ကို သုံး၍ ApiService မှတဆင့် Login လုပ်ဆောင်မည်။
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 💡 context.read ကို အသုံးပြုခြင်း
      final result = await context.read<ApiService>().login(
        _usernameController.text,
        _passwordController.text,
      );

      // Login အောင်မြင်ပါက (result['success'] == true) ဖြစ်ပါက၊
      // ApiService ထဲက notifyListeners() ကြောင့် AuthWrapper က Dashboard ကို အလိုအလျောက် သွားပါလိမ့်မည်။

      if (!result['success']) {
        if (mounted) {
          setState(() {
            _errorMessage =
                result['message'] ??
                'Login Failed: Server error or unauthorized.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Login Failed: Invalid credentials or API error. (Detail: ${e.toString()})';
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

  // --- Register Logic (Provider-based) ---
  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'စကားဝှက်နှစ်ခု မတူညီပါ။';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 💡 context.read ကို အသုံးပြုခြင်း
      await context.read<ApiService>().register(
        _usernameController.text,
        _passwordController.text,
      );

      // မှတ်ပုံတင်ပြီးပါက Login View သို့ ပြောင်းပြီး အောင်မြင်ကြောင်းပြမည်
      setState(() {
        _isLogin = true;
        _errorMessage =
            'မှတ်ပုံတင်ခြင်း အောင်မြင်ပါသည်။ ကျေးဇူးပြု၍ ဝင်ရောက်ပါ။';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('400')
            ? 'အသုံးပြုသူအမည် ရှိပြီးသား ဖြစ်နိုင်သည် သို့မဟုတ် အချက်အလက်မပြည့်စုံပါ။'
            : 'မှတ်ပုံတင်ရာတွင် အမှားတစ်ခု ဖြစ်ပေါ်ခဲ့သည်: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 💡 Course Selection Screen သို့ သွားသော Function
  void _navigateToCourseSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CourseSelectionScreen()),
    );
  }

  // --- Reusable Text Field (Glassmorphism style) ---
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
  Widget _buildGradientButton(String text, VoidCallback? onPressed) {
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

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(kDefaultPadding * 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassCard(
                  blurAmount: 15.0,
                  borderRadius: 20.0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 5.0,
                  ),
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

                        // Username Field
                        _buildTextField(
                          _usernameController,
                          'အသုံးပြုသူအမည်',
                          Icons.person,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        _buildTextField(
                          _passwordController,
                          'လျှို့ဝှက်နံပါတ်',
                          Icons.lock,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field (Register Only)
                        if (!_isLogin)
                          Column(
                            children: [
                              _buildTextField(
                                _confirmPasswordController,
                                'လျှို့ဝှက်နံပါတ် အတည်ပြုပါ',
                                Icons.lock_open,
                                isPassword: true,
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),

                        const SizedBox(height: 10),

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Login/Register Button
                        _buildGradientButton(
                          _isLogin ? 'ဝင်ရောက်ပါ' : 'မှတ်ပုံတင်ပါ',
                          _isLogin ? _handleLogin : _handleRegister,
                        ),

                        const SizedBox(height: 20),

                        // Switcher Button
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    _errorMessage = '';
                                    _usernameController.clear();
                                    _passwordController.clear();
                                    _confirmPasswordController.clear();
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

                const SizedBox(height: 30),

                // Course Selection Button (Browse as Guest)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _navigateToCourseSelection,
                  icon: const Icon(Icons.menu_book),
                  label: const Text('အကောင့်မဝင်ဘဲ သင်တန်းများ ကြည့်ရန်'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade500, // အရောင်အသစ်သုံး
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
