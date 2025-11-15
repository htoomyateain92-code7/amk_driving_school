import 'dart:convert';
import 'package:carapp/models/blog_model.dart';
import 'package:carapp/models/booking_model.dart';
import 'package:carapp/models/course_detail_model.dart';
import 'package:carapp/models/course_list_item_model.dart';
import 'package:carapp/models/course_model.dart';
import 'package:carapp/models/dashboard_model.dart';
import 'package:carapp/models/quiz_detail_model.dart';
import 'package:carapp/models/quiz_model.dart';
import 'package:carapp/models/session_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ✅ ပြင်ဆင်လိုက်သော URL: Android Emulator တွင် ချိတ်ဆက်ရန်အတွက် 10.0.2.2 ကို သုံးထားပါသည်။
// Physical Device အတွက်ဆိုပါက သင့် Local IP (ဥပမာ: 192.168.1.10) ကို အသုံးပြုပါ။
const String _baseUrl = 'http://localhost:8000/api/v1';
const String _loginUrl = 'http://localhost:8000/api/v1/token/';

class ApiService with ChangeNotifier {
  // --- State Properties ---
  String? _accessToken;
  String? _userName;
  String _userRole = 'guest';

  // --- Getters ---
  bool get isLoggedIn => _accessToken != null;
  String get userRole => _userRole;
  String? get userName => _userName;
  String? _refreshToken;

  // --- Constructor & Initial Load ---
  ApiService() {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    _refreshToken = prefs.getString(
      'refresh_token',
    ); // Refresh Token ကိုပါ ယူပါ

    if (token != null) {
      _accessToken = token;
      await _initializeUserDetails();
    }
    notifyListeners();
  }

  Future<void> _initializeUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/accounts/me/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        _userName = data['full_name'] ?? data['username'] ?? 'User';
        _userRole = data['role'] ?? 'student';
        notifyListeners();
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print(
            'Token Expired or Invalid during _initializeUserDetails. Logging out.',
          );
        }
        await logout();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user details: $e');
      }
      // Network Error သို့မဟုတ် အခြား Error ဖြစ်ပါက Logout လုပ်ပါ
      await logout();
    }
  }

  // --- Helpers ---
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    // JWT/Bearer Token ကို ထည့်သွင်းခြင်း
    if (requireAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    // 💡 DEBUGGING: Request Headers တွေကို Print ထုတ်ပေးခြင်း
    if (kDebugMode) {
      print('Generated Headers (Auth Required: $requireAuth): $headers');
    }

    return headers;
  }

  Future<void> _setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    _accessToken = token;
  }

  // --- Login Logic ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: await _getHeaders(requireAuth: false),
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data.containsKey('access')) {
          final String token = data['access'];
          final prefs = await SharedPreferences.getInstance();

          // 💡 Refresh Token ကိုပါ သိမ်းဆည်းရန်
          if (data.containsKey('refresh')) {
            await prefs.setString('refresh_token', data['refresh']);
            _refreshToken = data['refresh'];
          }

          await _setAccessToken(token);
          await _initializeUserDetails();

          notifyListeners();

          return {'success': true, 'role': _userRole};
        } else {
          return {
            'success': false,
            'message': 'Login အောင်မြင်သော်လည်း access token မပါဝင်ပါ။',
          };
        }
      } else {
        String errorMessage =
            'Login မအောင်မြင်ပါ (Status: ${response.statusCode})။';
        try {
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else if (errorData.containsKey('non_field_errors')) {
            errorMessage = errorData['non_field_errors'][0];
          }
        } catch (_) {}
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      // ✅ Base URL မှားယွင်းပါက SocketException ရရှိပါမည်။
      String detailedError = e.toString().contains('SocketException')
          ? 'Network ချိတ်ဆက်မှု ပြဿနာကြောင့် Login မအောင်မြင်ပါ။ Base URL ကို စစ်ဆေးပါ။'
          : 'Login ပြုလုပ်ရာတွင် အမှားတစ်ခု ဖြစ်ပေါ်ခဲ့သည်: ${e.toString()}';

      if (kDebugMode) {
        print('Login API Error: $e');
      }

      return {'success': false, 'message': detailedError};
    }
  }

  // --- Logout Logic ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    _accessToken = null;
    _refreshToken = null;
    _userRole = 'guest';
    _userName = null;
    notifyListeners();
  }

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/accounts/register/'),
      headers: await _getHeaders(requireAuth: false),
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'role': 'student', // Default role
      }),
    );

    if (response.statusCode != 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      throw Exception('Registration Failed: ${data.toString()}');
    }
  }

  Future<bool> _refreshTokenLogic() async {
    if (_refreshToken == null) {
      if (kDebugMode) print('No Refresh Token available.');
      await logout();
      // ❌ Error message ကို ပိုရှင်းလင်းအောင် ပြောင်းရန်အတွက်၊ ဒီမှာ Exception ထပ်မထည့်ပါ
      return false;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _setAccessToken(data['access']);
      if (data.containsKey('refresh')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('refresh_token', data['refresh']);
        _refreshToken = data['refresh'];
      }
      if (kDebugMode) print('Token successfully refreshed.');
      return true;
    }

    if (kDebugMode) print('Refresh Token Failed. Logging out.');
    await logout();
    return false;
  }

  // --- Dashboard Calls ---

  Future<OwnerDashboardData> fetchOwnerDashboardData() async {
    // 1. 💡 DEBUGGING: API Call မလုပ်ခင် Token ကို စစ်ဆေးပါ။
    if (kDebugMode) {
      print('--- Attempting fetchOwnerDashboardData ---');
      print('Current Access Token: $_accessToken');
      if (_accessToken == null) {
        print(
          'CRITICAL: _accessToken is NULL. Cannot make authenticated call (expect 401).',
        );
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/owner-dashboard/'),
        // 2. _getHeaders() ကို ခေါ်လိုက်တာနဲ့ Header တွေကို log လုပ်ပါလိမ့်မယ်။
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        return OwnerDashboardData.fromJson(body);
      } else if (response.statusCode == 401) {
        // Token သက်တမ်းကုန်နေပြီဆိုရင် Refresh လုပ်ကြည့်ပါ။
        if (kDebugMode) print('Received 401. Attempting token refresh...');

        // 3. 💡 Token Refresh မအောင်မြင်ပါက ပိုရှင်းလင်းသည့် Error Message ပြန်ရန် ပြင်ဆင်
        if (await _refreshTokenLogic()) {
          // Refresh အောင်မြင်ပါက၊ Call ကို ထပ်ခေါ်ပါ။
          return await fetchOwnerDashboardData();
        }

        // Token လုံးဝမရှိ/Refresh မရပါက ဒီ Error ကို ပြန်ပေးပါမည်။
        throw Exception('Access Denied. Please log in to view the dashboard.');
      } else {
        throw Exception(
          'Failed to load owner dashboard data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) print('Error in fetchOwnerDashboardData: $e');
      rethrow;
    }
  }

  Future<T> _executeDashboardCall<T>(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      if (T == OwnerDashboardData) {
        return OwnerDashboardData.fromJson(body) as T;
      } else if (T == InstructorDashboardData) {
        return InstructorDashboardData.fromJson(body) as T;
      } else if (T == StudentDashboardData) {
        return StudentDashboardData.fromJson(body) as T;
      }
    }

    throw Exception(
      'Failed to load dashboard data. Status: ${response.statusCode}',
    );
  }

  Future<InstructorDashboardData> fetchInstructorDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/instructor-dashboard/'),
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        return InstructorDashboardData.fromJson(body);
      } else if (response.statusCode == 401) {
        if (await _refreshTokenLogic()) {
          return await fetchInstructorDashboardData();
        }
        throw Exception('Access Denied. Please log in to view the dashboard.');
      } else {
        throw Exception(
          'Failed to load instructor dashboard data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentDashboardData> fetchStudentDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/student-dashboard/'),
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        return StudentDashboardData.fromJson(body);
      } else if (response.statusCode == 401) {
        if (await _refreshTokenLogic()) {
          return await fetchStudentDashboardData();
        }
        throw Exception('Access Denied. Please log in to view the dashboard.');
      } else {
        throw Exception(
          'Failed to load student dashboard data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------
  // --- 1. COURSE MANAGEMENT (CRUD & Detail) ---
  // ---------------------------

  // 1.1. [READ/LIST]: Courses စာရင်း (Admin Dashboard အတွက်)
  Future<List<Course>> fetchCourses({required bool isPublic}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/courses/'),
      headers: await _getHeaders(requireAuth: !isPublic),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Course.fromJson(item)).toList();
    }
    if (response.statusCode == 401 && isPublic) {
      return [];
    }

    throw Exception('Failed to load courses. Status: ${response.statusCode}');
  }

  // 1.2. [READ/LIST]: Public Course List (CourseListItem Model ကို သုံးသည်)
  Future<List<CourseListItem>> fetchPublicCourseList() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/courses/public_list/'),
      headers: await _getHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => CourseListItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load public course list');
    }
  }

  // 1.3. [READ/DETAIL]: Course အသေးစိတ် (Booking Screen အတွက်)
  Future<CourseDetail> fetchCourseDetail(int courseId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/courses/$courseId/'),
      headers: await _getHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return CourseDetail.fromJson(data);
    } else {
      throw Exception(
        'Failed to load course details for ID $courseId. Status: ${response.statusCode}',
      );
    }
  }

  // 1.4. [CREATE]: Course အသစ် ဖန်တီးခြင်း
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/courses/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 201) {
      return Course.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
        'Failed to create course. Status: ${response.statusCode}',
      );
    }
  }

  // 1.5. [UPDATE]: Course ပြင်ဆင်ခြင်း
  Future<Course> updateCourse(int id, Course course) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/courses/$id/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200) {
      return Course.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
        'Failed to update course. Status: ${response.statusCode}',
      );
    }
  }

  // 1.6. [DELETE]: Course ဖျက်ခြင်း
  Future<void> deleteCourse(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/courses/$id/'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete course. Status: ${response.statusCode}',
      );
    }
  }

  // ---------------------------
  // --- 2. SESSION MANAGEMENT (CRUD & Batch Fetch) ---
  // ---------------------------

  // 2.1. [READ/LIST]: Sessions အားလုံး (Admin/Instructor အတွက်)
  Future<List<Session>> fetchSessions() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sessions/'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Session.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load sessions. Status: ${response.statusCode}',
      );
    }
  }

  // 2.2. [READ/LIST]: Batch ID ဖြင့် Session စာရင်းကို ယူသည် (Booking/Public အတွက်)
  Future<List<Session>> fetchSessionsByBatch(int batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sessions/?batch_id=$batchId'),
      headers: await _getHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Session.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load sessions for batch (ID: $batchId). Status: ${response.statusCode}',
      );
    }
  }

  // 2.3. [CREATE]: Session အသစ် ဖန်တီးခြင်း
  Future<Session> createSession(Session session) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/sessions/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode(session.toJson()),
    );

    if (response.statusCode == 201) {
      return Session.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(
        'Failed to create session. Details: ${errorBody.toString()}',
      );
    }
  }

  // 2.4. [UPDATE]: Session ပြင်ဆင်ခြင်း
  Future<Session> updateSession(int id, Session session) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/sessions/$id/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode(session.toJson()),
    );

    if (response.statusCode == 200) {
      return Session.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
        'Failed to update session. Status: ${response.statusCode}',
      );
    }
  }

  // 2.5. [DELETE]: Session ဖျက်ခြင်း
  Future<void> deleteSession(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/sessions/$id/'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete session. Status: ${response.statusCode}',
      );
    }
  }

  // 💡 NEW: Session Data များကို ခေါ်ယူခြင်း (Batch ID ဖြင့် Filter လုပ်သည်)
  Future<List<CourseSession>> fetchSessionsForBatch(int batchId) async {
    // Django REST API Endpoint: /api/v1/sessions/?batch=<batchId>
    final url = Uri.parse('$_baseUrl/sessions/?batch=$batchId');

    final response = await http.get(
      url,
      headers: await _getHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => CourseSession.fromJson(json)).toList();
    } else {
      // API ခေါ်ယူမှု အဆင်မပြေရင် Empty List ပြန်ပေးပါမည်။
      if (kDebugMode) {
        print(
          'Failed to load sessions for batch $batchId: ${response.statusCode}',
        );
      }
      return [];
    }
  }

  // ---------------------------
  // --- 3. BOOKING MANAGEMENT (CRUD) ---
  // ---------------------------

  Future<bool> createBooking(
    Set<int> sessionIds, {
    required int courseId,
    required int batchId,
  }) async {
    // 1. URL
    final url = '$_baseUrl/bookings/';

    // 2. Data တွေ Empty မဖြစ်ဖို့ သေချာစစ်ဆေးပါ
    if (courseId == 0 || sessionIds.isEmpty) {
      if (kDebugMode) {
        print("ERROR: Course ID or Session IDs are missing before API call.");
      }
      return false;
    }

    // 3. Payload
    final payload = {
      'sessions': sessionIds.toList(), // List of IDs (e.g., [1, 5, 6])
      'course': courseId, // Single ID (e.g., 42)
      // Note: batch_id ကို server မှာ handle လုပ်ပါက ဒီမှာ ထည့်စရာမလိုပါ
    };

    // 4. Headers
    final headers = await _getHeaders(requireAuth: true);

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload), // jsonEncode() ကို သေချာသုံးပါ
    );

    // ... (Response logic) ...
    if (response.statusCode == 201) {
      return true; // Booking အောင်မြင်သည်
    } else {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['detail'] ?? 'Failed to create booking.');
    }
  }

  // 3.2. [READ/LIST]: User ရဲ့ Booking မှတ်တမ်းအားလုံးကို ယူသည်
  Future<List<Booking>> fetchMyBookings() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bookings/my_bookings/'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Booking.fromJson(json)).toList();
    } else if (response.statusCode == 404 || response.statusCode == 401) {
      // 401 ရပါက Token Refresh Logic ကို Dashboard Call တွေမှာပဲ ထားပါမည်။
      return [];
    } else {
      throw Exception(
        'Failed to load user bookings. Status: ${response.statusCode}',
      );
    }
  }

  // 3.3. [READ/DETAIL]: Booking တစ်ခုတည်းကို အသေးစိတ် ကြည့်ခြင်း
  Future<Booking> fetchBookingDetail(int bookingId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bookings/$bookingId/'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return Booking.fromJson(data);
    } else {
      throw Exception(
        'Failed to load booking detail (ID: $bookingId). Status: ${response.statusCode}',
      );
    }
  }

  // 3.4. [UPDATE]: Booking အခြေအနေ (Status) ပြောင်းလဲခြင်း (e.g., Cancel)
  Future<bool> updateBookingStatus(int bookingId, String newStatus) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/bookings/$bookingId/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(
        errorData['detail'] ?? 'Failed to update booking status.',
      );
    }
  }

  // 💡 Convenience method: Booking Cancel လုပ်ခြင်း
  Future<bool> cancelBooking(int bookingId) async {
    return updateBookingStatus(bookingId, 'Cancelled');
  }

  // 3.5. [DELETE]: Booking ကို ဖျက်ခြင်း (Hard Delete)
  Future<void> deleteBooking(int bookingId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/bookings/$bookingId/'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete booking (ID: $bookingId).');
    }
  }

  // ---------------------------
  // --- 4. QUIZ MANAGEMENT (CRUD & Detail) ---
  // ---------------------------

  // 4.1. [READ/LIST]: Quizzes စာရင်း
  Future<List<Quiz>> fetchQuizzes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/quizzes/'),
      headers: await _getHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Quiz.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      return [];
    } else {
      throw Exception('Failed to load quizzes. Status: ${response.statusCode}');
    }
  }

  // 4.2. [READ/DETAIL]: Quiz Questions
  Future<QuizDetail> fetchQuizQuestions(int quizId) async {
    // 💡 URL နောက်က slash (/) ကို ဖယ်လိုက်ပါ
    final String endpoint = '$_baseUrl/quizzes/$quizId/questions/';
    final response = await http.get(
      Uri.parse(endpoint),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(
        utf8.decode(response.bodyBytes),
      );

      // 💡 [စစ်ဆေးရန်]: data ကို တိုက်ရိုက် သုံးနိုင်/မသုံးနိုင် စစ်ပါ
      return QuizDetail.fromJson(data);
    } else {
      // 🛑 404 Error ပြန်လာရင် Server URL/Routing ကို ပြန်စစ်ပါ။
      throw Exception(
        'Failed to load quiz questions for ID $quizId. Status: ${response.statusCode}',
      );
    }
  }

  // 4.3. [CREATE]: Quiz အသစ် ဖန်တီးခြင်း
  Future<Quiz> createQuiz(Quiz quiz) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/quizzes/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode(quiz.toJson()),
    );

    if (response.statusCode == 201) {
      return Quiz.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create quiz. Status: ${response.statusCode}');
    }
  }

  // 4.4. [UPDATE]: Quiz ပြင်ဆင်ခြင်း
  Future<Quiz> updateQuiz(int id, Quiz quiz) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/quizzes/$id/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode(quiz.toJson()),
    );

    if (response.statusCode == 200) {
      return Quiz.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update quiz. Status: ${response.statusCode}');
    }
  }

  // 4.5. [DELETE]: Quiz ဖျက်ခြင်း
  Future<void> deleteQuiz(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/quizzes/$id/'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete quiz. Status: ${response.statusCode}');
    }
  }

  // ---------------------------
  // --- 5. BLOG MANAGEMENT (CRUD & Detail) ---
  // ---------------------------

  // 5.1. [READ/LIST]: Blogs စာရင်း
  Future<List<Blog>> fetchBlogs() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/public/articles/'),
      headers: await _getHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Blog.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load blogs. Status: ${response.statusCode}');
    }
  }

  // 5.2. [READ/DETAIL]: Blog အသေးစိတ်
  Future<Map<String, dynamic>> fetchBlogDetail(int blogId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/public/articles/$blogId/'),
      headers: await _getHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return data;
    } else {
      throw Exception(
        'Failed to load blog detail for ID $blogId. Status: ${response.statusCode}',
      );
    }
  }

  // 5.3. [CREATE]: Blog အသစ် ဖန်တီးခြင်း
  Future<Blog> createBlog(Blog blog) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/public/articles/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode(blog.toJson()),
    );

    if (response.statusCode == 201) {
      return Blog.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create blog. Status: ${response.statusCode}');
    }
  }

  // 5.4. [UPDATE]: Blog ပြင်ဆင်ခြင်း
  Future<Blog> updateBlog(int id, Blog blog) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/public/articles/$id/'),
      headers: await _getHeaders(requireAuth: true),
      body: jsonEncode(blog.toJson()),
    );

    if (response.statusCode == 200) {
      return Blog.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update blog. Status: ${response.statusCode}');
    }
  }

  // 5.5. [DELETE]: Blog ဖျက်ခြင်း
  Future<void> deleteBlog(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/public/articles/$id/'),
      headers: await _getHeaders(requireAuth: true),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete blog. Status: ${response.statusCode}');
    }
  }
}
