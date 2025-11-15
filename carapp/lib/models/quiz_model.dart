// lib/models/quiz_model.dart

class Quiz {
  final int id;
  final String title;
  final String description;
  final int courseId;
  final int durationMinutes;
  final bool isPublished;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.durationMinutes,
    required this.isPublished,
    required this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    // 💡 [FIX 1]: id ကို Nullable int အဖြစ်ယူပြီး 0 ကို default ပေးခြင်း
    final int id = (json['id'] as int?) ?? 0;

    // 💡 [FIX 2]: courseId - API က 'course' ကို ID သို့မဟုတ် Object ပေးနိုင်သည်
    int parsedCourseId = 0;
    if (json['course'] is int) {
      // 'course': 1
      parsedCourseId = json['course'] as int;
    } else if (json['course'] is Map) {
      // 'course': {'id': 1, 'title': '...'}
      parsedCourseId = (json['course']['id'] as int?) ?? 0;
    }

    // 💡 [CHECK 3]: duration_minutes သို့မဟုတ် time_limit_sec ကို API အရ ကိုက်ညီအောင် ပြင်ပါ။
    // durationMinutes: json['duration_minutes'] ?? 0, // အကယ်၍ API က 'duration_minutes' ပေးရင်
    final int duration =
        (json['time_limit_sec'] as int?) ??
        0; // အကယ်၍ API က 'time_limit_sec' ပေးရင်

    // 💡 [FIX 4]: DateTime parsing error ကို ရှောင်ရှားရန်
    DateTime parsedCreatedAt = DateTime.now();
    try {
      if (json['created_at'] != null) {
        parsedCreatedAt = DateTime.parse(json['created_at'] as String);
      }
    } catch (e) {
      print('Error parsing Quiz createdAt: $e');
    }

    return Quiz(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      courseId: parsedCourseId,
      // 💡 [CHECK]: သင်၏ API Field Name ပေါ်မူတည်၍ ရွေးချယ်ပါ
      durationMinutes: duration,
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: parsedCreatedAt,
    );
  }

  // ... (toJson method is OK) ...
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'course': courseId,
      'duration_minutes':
          durationMinutes, // 💡 durationMinutes ကို duration_minutes ပဲထားလိုက်ပါ
      'is_published': isPublished,
    };
  }
}
