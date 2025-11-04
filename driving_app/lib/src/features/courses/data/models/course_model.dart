class Course {
  final int id;
  final String title;
  final String code;
  final String description;
  final double totalDurationHours;

  // ✅ လိုအပ်သော Fields များ ပြန်ထည့်သွင်းခြင်း
  // (Backend CourseDetailSerializer မှ တွက်ချက်ပေးသော data များ)
  final int requiredSessions;
  final int maxSessionDurationMinutes;

  final List<Batch> batches;

  Course({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.totalDurationHours,
    required this.requiredSessions, // ထပ်တိုး
    required this.maxSessionDurationMinutes, // ထပ်တိုး
    required this.batches,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Safely parse batches
    var batchList = <Batch>[];
    if (json['batches'] != null && json['batches'] is List) {
      batchList = (json['batches'] as List)
          .map((batchJson) => Batch.fromJson(batchJson))
          .toList();
    }

    return Course(
      // Safely parse ID
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      // Safely parse the duration
      totalDurationHours:
          double.tryParse(json['total_duration_hours']?.toString() ?? '') ??
              0.0,

      // ✅ Missing fields parsing
      requiredSessions: json['required_sessions'] is int
          ? json['required_sessions']
          : (int.tryParse(json['required_sessions']?.toString() ?? '') ?? 0),
      maxSessionDurationMinutes: json['max_session_duration_minutes'] is int
          ? json['max_session_duration_minutes']
          : (int.tryParse(
                  json['max_session_duration_minutes']?.toString() ?? '') ??
              0),

      batches: batchList,
    );
  }
}

class Batch {
  final int id;
  final String title;
  final String instructorName;
  // ✅ လိုအပ်သော Field ပြန်ထည့်သွင်းခြင်း (Session တွက်ရန် လိုအပ်သည်)
  final DateTime startDate;
  final DateTime endDate;

  Batch({
    required this.id,
    required this.title,
    required this.instructorName,
    required this.startDate, // ထပ်တိုး
    required this.endDate,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? '',
      // Assuming instructor is a nested object
      instructorName: json['instructor']?['username'] ?? 'N/A',
      // ✅ startDate ကို Parse လုပ်ခြင်း
      // 🛑 ပြင်ဆင်ချက်: App တစ်ခုလုံးမှာ Timezone တူညီစေရန် UTC သို့ ပြောင်းလဲခြင်း။
      // ဤနေရာတွင် toUtc() မပါသောကြောင့် အချိန်တွက်ချက်မှုများ လွဲမှားနေခြင်းဖြစ်သည်။
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}
