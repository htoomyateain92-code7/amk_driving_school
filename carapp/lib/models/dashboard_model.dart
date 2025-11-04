// lib/models/dashboard_model.dart

class OwnerDashboardData {
  final double totalRevenue; // စုစုပေါင်းဝင်ငွေ (ဥပမာ- ၅.၆ သိန်း)
  final int totalStudents; // ကျောင်းသားဦးရေ (ဥပမာ- +၃၂ ဦး)
  final int activeCourses; // ဖွင့်လှစ်ထားသော သင်တန်းအရေအတွက် (ဥပမာ- ၅ ခု)

  OwnerDashboardData({
    required this.totalRevenue,
    required this.totalStudents,
    required this.activeCourses,
  });

  // 💡 Factory method for API (Django JSON data)
  factory OwnerDashboardData.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardData(
      totalRevenue: double.tryParse(json['total_revenue'].toString()) ?? 0.0,
      totalStudents: json['total_students'] as int? ?? 0,
      activeCourses: json['active_courses'] as int? ?? 0,
    );
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
}
