import 'dart:convert';
import 'package:intl/intl.dart';

import 'session_model.dart';

class CourseSession {
  final int id;
  final int batchId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String courseTitle;

  CourseSession({
    required this.id,
    required this.batchId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.courseTitle,
  });

  factory CourseSession.fromJson(Map<String, dynamic> json) {
    // 💡 API မှ start_dt/end_dt သည် ISO 8601 format ဖြစ်၍ DateTime.parse ကို သုံးသည်
    return CourseSession(
      id: json['id'] as int? ?? 0,
      batchId: json['batch'] as int? ?? 0,
      startTime: DateTime.parse(json['start_dt']),
      endTime: DateTime.parse(json['end_dt']),
      status: json['status'] as String? ?? 'unknown',
      courseTitle: json['course_title'] as String? ?? 'N/A',
    );
  }

  // Session တစ်ခု၏ ကြာချိန်ကို တွက်ချက်သည် (မိနစ်ဖြင့်)
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  // ပြသရန် လွယ်ကူသော Time Format
  String get formattedTime => DateFormat('h:mm a').format(startTime);

  // ပြသရန် လွယ်ကူသော Date Format
  String get formattedDate => DateFormat('MMM d, yyyy (E)').format(startTime);
}

// CourseDetail (သင်တန်းအသေးစိတ်) Model
class CourseDetail {
  final int id;
  final String title;
  final String code;
  final String description;
  final String? totalDurationHours;
  final int? maxSessionDurationMinutes;
  final int? requiredSessions;
  final String price;
  final bool isPublic;
  final int? durationDays;
  final int? sessionCount;

  // 💡 သင်၏ API Response မှ ရသော batches list ကို လက်ခံသည်
  final List<dynamic> batches;
  final List<String> features;

  CourseDetail({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    this.totalDurationHours,
    this.maxSessionDurationMinutes,
    this.requiredSessions,
    required this.price,
    required this.isPublic,
    this.durationDays,
    this.sessionCount,
    required this.batches, // 💡 batches list ကို constructor ထဲ ထည့်လိုက်ပါ
    required this.features,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    // Features array ကို ရှင်းလင်းပြီးယူခြင်း
    final List<String> features = (json['features'] is List)
        ? (json['features'] as List).map((e) => e.toString()).toList()
        : [];

    // Duration Days ကို duration_days ဒါမှမဟုတ် days ကနေယူပါ
    final int? durationDays =
        json['duration_days'] as int? ?? json['days'] as int?;

    return CourseDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'N/A',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? 'No description.',
      totalDurationHours: json['total_duration_hours'] as String?,
      maxSessionDurationMinutes: json['max_session_duration_minutes'] as int?,
      requiredSessions: json['required_sessions'] as int?,
      price: json['price'] as String? ?? '0',
      isPublic: json['is_public'] as bool? ?? false,
      durationDays: durationDays,
      sessionCount: json['session_count'] as int?,

      batches: json['batches'] as List? ?? [], // 💡 batches list ကို JSON ကနေယူ
      features: features,
    );
  }

  // 💡 NEW GETTER: Session များကို ခေါ်ယူရန် ပထမဆုံး Batch ID ကို ရယူခြင်း
  int? get batchIdToFetch {
    // batches list ထဲမှာ အနည်းဆုံး တစ်ခုရှိပြီး၊ ၎င်းသည် Map ဖြစ်ပါက ပထမဆုံး Batch ရဲ့ ID ကို ယူမယ်
    if (batches.isNotEmpty && batches.first is Map) {
      return (batches.first as Map<String, dynamic>)['id'] as int?;
    }
    // အကယ်၍ batches key မပါခဲ့ရင် null ပြန်ပေးပါမယ်
    return null;
  }

  // ဈေးနှုန်းကို double အနေဖြင့် ရယူသည်
  double get priceValue {
    final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }
}
