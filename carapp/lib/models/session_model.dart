import 'package:intl/intl.dart';

class Session {
  final int id;
  final int batchId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String courseTitle;

  Session({
    required this.id,
    required this.batchId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.courseTitle,
  });

  // [READ] API မှ Data များကို Object အဖြစ် ပြောင်းရန် (FROM JSON)
  factory Session.fromJson(Map<String, dynamic> json) {
    // 💡 FIX 1: int? ?? 0 ဖြင့် null-safe ပြုလုပ်ခြင်း
    // final int safeBatchId = json['batch_id'] as int? ?? 0;

    // // 💡 FIX 2: String null ဖြစ်ခဲ့လျှင် DateTime.now() ကို Default ပြုလုပ်ခြင်း
    // final String? startDtString = json['start_dt'] as String?;
    // final String? endDtString = json['end_dt'] as String?;

    // final DateTime safeStartDt = startDtString != null
    //     ? (DateTime.tryParse(startDtString) ?? DateTime.now())
    //     : DateTime.now();

    // final DateTime safeEndDt = endDtString != null
    //     ? (DateTime.tryParse(endDtString) ?? DateTime.now())
    //     : DateTime.now();

    return Session(
      id: json['id'] as int? ?? 0,
      batchId: json['batch'] as int? ?? 0,
      startTime: DateTime.parse(json['start_dt']),
      endTime: DateTime.parse(json['end_dt']),
      status: json['status'] as String? ?? 'unknown',
      courseTitle: json['course_title'] as String? ?? '',
    );
  }

  // 💡 [CREATE/UPDATE] Object မှ Data များကို API သို့ ပို့ရန် Map အဖြစ် ပြောင်းလဲခြင်း (TO JSON)
  Map<String, dynamic> toJson() {
    return {
      // Create/Update အတွက် ID ကို API Body တွင် ပို့ရန် မလို
      'batch_id': batchId,
      // 💡 DateTime များကို Backend လိုအပ်သော ISO 8601 String Format သို့ ပြောင်းလဲခြင်း
      'start_dt': startTime,
      'end_dt': endTime,
      'status': status,
      'course_title': courseTitle,
    };
  }

  // Session တစ်ခု၏ ကြာချိန်ကို တွက်ချက်သည် (မိနစ်ဖြင့်)
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  // ပြသရန် လွယ်ကူသော Time Format
  String get formattedTime => DateFormat('h:mm a').format(startTime);

  // ပြသရန် လွယ်ကူသော Date Format
  String get formattedDate => DateFormat('MMM d, yyyy (E)').format(startTime);
}
