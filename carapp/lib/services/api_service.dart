// lib/services/api_service.dart

import 'dart:convert';
import 'package:carapp/models/dashboard_model.dart';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

// 💡 သင့် Django REST API ရဲ့ Base URL ကို ဤနေရာတွင် ထည့်သွင်းပါ
// Local Development အတွက် 10.0.2.2 (Android Emulator) သို့မဟုတ် localhost (Web/iOS Simulator) ကို သုံးပါ။
const String _baseUrl = 'http://localhost:8000/api/v1/';

class ApiService {
  // --- GET All Courses ---
  Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse('$_baseUrl/courses/'));

    if (response.statusCode == 200) {
      // 💡 Django REST framework မှ ပြန်လာသော JSON Array
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));

      List<Course> courses = body
          .map((dynamic item) => Course.fromJson(item))
          .toList();

      return courses;
    } else {
      // Error handling (e.g., 404, 500)
      throw Exception(
        'Failed to load courses from API. Status: ${response.statusCode}',
      );
    }
  }

  // --- Login Function (အနာဂတ်အတွက်) ---
  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Django token ကို ပြန်ပေးသည်ဟု ယူဆသည်
      return data['token'];
    } else {
      throw Exception('Login Failed. Status: ${response.statusCode}');
    }
  }

  // --- Register Function ---
  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/accounts/register/',
      ), // 💡 သင့် Django Register URL ကို ထည့်ပါ
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        // [TODO]: email, first_name စသည့် လိုအပ်သော fields များ ထပ်ထည့်ပါ
      }),
    );

    if (response.statusCode != 201) {
      // 201 Created ကို မျှော်လင့်သည်
      final data = json.decode(response.body);
      throw Exception(
        'Registration Failed: ${data['detail'] ?? 'Unknown error'}',
      );
    }

    // --- GET Owner Dashboard Data ---
    Future<OwnerDashboardData> fetchOwnerDashboardData() async {
      // 💡 Django မှာ Dashboard Data ကို တစ်ကြိမ်တည်း ပြန်ပေးမယ့် Endpoint ကို ခေါ်ယူပါမည်
      final response = await http.get(Uri.parse('$_baseUrl/owner-dashboard/'));

      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(
          utf8.decode(response.bodyBytes),
        );

        // JSON body ကို OwnerDashboardData model သို့ ပြောင်းပါ
        return OwnerDashboardData.fromJson(body);
      } else {
        // Error handling (e.g., Authentication error)
        throw Exception(
          'Failed to load owner dashboard data. Status: ${response.statusCode}',
        );
      }
    }
  }
}
