import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Token သိမ်းဆည်းရန်အတွက်

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 💡 FIX: AuthService Instance ကို Field အဖြစ် မှန်ကန်စွာ ကြေညာပါ
  late final AuthService _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); // Register အတွက်

  // Login/Register ကို ပြောင်းရန် State
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // 💡 စာရင်းသွင်းခြင်း (သို့) Login ဝင်ခြင်းကို ကိုင်တွယ်သော Method
  void _submitAuthForm() async {
    // ဤနေရာတွင် Form Validation Logic များ ထပ်ထည့်နိုင်ပါသည်။
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email နှင့် Password အပြည့်အစုံ ထည့်သွင်းပါ။'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------
      // 💡 REAL AUTHENTICATION LOGIC HERE
      // ----------------------------------------------------

      String token = '';
      String successMessage = '';

      if (_isLogin) {
        // Login API Call Logic
        // ... await _apiService.login(email, password) ...

        // နေရာယူထားသော Token
        token = 'logged_in_user_token_${_emailController.text}';
        successMessage = 'Login အောင်မြင်ပါပြီ။';
      } else {
        // Register API Call Logic
        // ... await _apiService.register(username, email, password) ...

        // နေရာယူထားသော Token (Register ပြီးရင် Login ဝင်ပြီးသားလို့ ယူဆပါမည်)
        token = 'new_registered_token_${_emailController.text}';
        successMessage = 'စာရင်းသွင်းခြင်း အောင်မြင်ပြီးပါပြီ။';
      }

      // 💡 FIX: _authService instance ကို သုံးပြီး Token သိမ်းဆည်းခြင်း
      await _authService.saveToken(token);

      // UI ကို Update လုပ်ရန်
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      // Course Detail Screen ကို true ဖြင့် ပြန်ပို့ခြင်း (Booking Logic ကို ဆက်လုပ်ရန်)
      Navigator.of(context).pop(true);
    } catch (e) {
      // API error ကိုင်တွယ်ခြင်း
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('လုပ်ဆောင်မှု မအောင်မြင်ပါ: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login ဝင်ရန်' : 'အကောင့်ဖွင့်ရန်'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            // --- Toggle Button (Login/Register) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleChip('Login', true),
                const SizedBox(width: 10),
                _buildToggleChip('Register', false),
              ],
            ),
            const SizedBox(height: 40),

            // --- Forms ---
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Username Field (Register မှသာ ပြပါမည်)
                    if (!_isLogin)
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    if (!_isLogin) const SizedBox(height: 15),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitAuthForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _isLogin ? 'Login ဝင်ပါ' : 'အကောင့်ဖွင့်ပါ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Login/Register Toggle Chip UI
  Widget _buildToggleChip(String label, bool isLoginOption) {
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: _isLogin == isLoginOption ? Colors.white : Colors.indigo,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: _isLogin == isLoginOption ? Colors.indigo : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.indigo),
      ),
      onPressed: () {
        setState(() {
          _isLogin = isLoginOption;
        });
      },
    );
  }
}
