// lib/models/dashboard_model.dart

class OwnerDashboardData {
  final double totalRevenue; // စုစုပေါင်းဝင်ငွေ (ဥပမာ- ၅.၆ သိန်း)
  final int totalStudents; // ကျောင်းသားဦးရေ (ဥပမာ- +၃၂ ဦး)
  final int totalInstructors;
  final int activeCourses; // ဖွင့်လှစ်ထားသော သင်တန်းအရေအတွက် (ဥပမာ- ၅ ခု)
  final double monthlyRevenue;

  OwnerDashboardData({
    required this.totalRevenue,
    required this.totalStudents,
    required this.totalInstructors,
    required this.activeCourses,
    required this.monthlyRevenue,
  });

  // 💡 Factory method for API (Django JSON data)
  factory OwnerDashboardData.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardData(
      totalRevenue: double.tryParse(json['total_revenue'].toString()) ?? 0.0,
      totalStudents: json['total_students'] as int? ?? 0,
      totalInstructors: json['total_instructors'] ?? 0,
      activeCourses: json['active_courses'] as int? ?? 0,
      monthlyRevenue: (json['monthly_revenue'] is String)
          ? double.tryParse(json['monthly_revenue']) ?? 0.0
          : (json['monthly_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_instructors': totalInstructors,
      'active_courses': activeCourses,
      'monthly_revenue': monthlyRevenue,
    };
  }
}

class InstructorDashboardData {
  final String schedule; // ဥပမာ- 'မနက် ၈:၀၀ မှ ၁၀:၀၀ - အခြေခံအုပ်စု (A)'
  final String
  studentNote; // ဥပမာ- 'ကျောင်းသား ၅ ဦး Quiz ဖြေဆိုရန် ကျန်ရှိနေသည်'
  final int teachingTips; // ဥပမာ- ၅ ခု

  InstructorDashboardData({
    required this.schedule,
    required this.studentNote,
    required this.teachingTips,
  });

  // 💡 [FIX] JSON Map မှ Data များကို Class Object အဖြစ် ပြောင်းလဲခြင်း
  factory InstructorDashboardData.fromJson(Map<String, dynamic> json) {
    // 💡 JSON Key များကို စနစ်တကျ ခေါ်ယူပြီး Data Type ကို သေချာအောင် as Type? ?? defaultValue ဖြင့် စစ်ဆေးထားသည်။
    return InstructorDashboardData(
      // 1. schedule (String)
      schedule: json['schedule'] as String? ?? 'No Schedule Available',

      // 2. studentNote (String) - JSON field ကို 'student_note' ဟု ယူဆသည်။
      studentNote:
          json['student_note'] as String? ?? 'No new notes from students.',

      // 3. teachingTips (int) - JSON field ကို 'teaching_tips' ဟု ယူဆသည်။
      teachingTips: json['teaching_tips'] as int? ?? 0,
    );
  }

  // 💡 [NEW] Update/Create အတွက် toJson() ကိုလည်း ထည့်သွင်းထားသည် (လိုအပ်ပါက)
  Map<String, dynamic> toJson() {
    return {
      'schedule': schedule,
      'student_note': studentNote,
      'teaching_tips': teachingTips,
    };
  }
}

class StudentUpcomingSession {
  final int id;
  final String batchTitle;
  final DateTime startDt;
  final DateTime endDt;
  final String status;

  StudentUpcomingSession({
    required this.id,
    required this.batchTitle,
    required this.startDt,
    required this.endDt,
    required this.status,
  });

  factory StudentUpcomingSession.fromJson(Map<String, dynamic> json) {
    return StudentUpcomingSession(
      id: json['id'] as int,
      batchTitle: json['batch_title'] as String,
      startDt: DateTime.parse(json['start_dt'] as String),
      endDt: DateTime.parse(json['end_dt'] as String),
      status: json['status'] as String,
    );
  }
}

// Student Dashboard ၏ အဓိက Data Model (StudentDashboardSerializer မှ လာသည်)
class StudentDashboardData {
  final int enrolledCourseCount;
  final int completedSessions;
  final int totalSessions;
  final double progressPercentage;
  final List<StudentUpcomingSession> upcomingSessions;
  final double? lastQuizScore; // Null ဖြစ်နိုင်သည်

  StudentDashboardData({
    required this.enrolledCourseCount,
    required this.completedSessions,
    required this.totalSessions,
    required this.progressPercentage,
    required this.upcomingSessions,
    this.lastQuizScore,
  });

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    var upcomingList = json['upcoming_sessions'] as List;
    List<StudentUpcomingSession> upcoming = upcomingList
        .map((i) => StudentUpcomingSession.fromJson(i))
        .toList();

    return StudentDashboardData(
      enrolledCourseCount: json['enrolled_course_count'] as int,
      completedSessions: json['completed_sessions'] as int,
      totalSessions: json['total_sessions'] as int,
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      upcomingSessions: upcoming,
      lastQuizScore: (json['last_quiz_score'] as num?)
          ?.toDouble(), // Nullable ဖြစ်အောင် သတ်မှတ်
    );
  }
}
