// lib/features/auth/screens/guest_home_screen.dart

import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Text(
              'Welcome to\nAMK Driving School',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                      blurRadius: 10, color: Colors.blueAccent.withOpacity(0.5))
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Your journey to safe driving starts here.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            _buildFeatureRow(Icons.school_outlined, 'Browse Driving Courses'),
            _buildFeatureRow(Icons.article_outlined, 'Read Safety Blogs'),
            _buildFeatureRow(Icons.quiz_outlined, 'Practice with Quizzes'),
            const Spacer(flex: 1),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Login', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(250, 50),
                side: const BorderSide(color: Colors.deepPurple),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text('Create an Account',
                  style: TextStyle(fontSize: 18)),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
