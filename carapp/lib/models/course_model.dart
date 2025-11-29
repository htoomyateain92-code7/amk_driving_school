// lib/models/course_model.dart (Final Fixed Version - Null Safety Ensured)

class Course {
  final int id;
  // 💡 [FIXED]: API က null ပြန်လာနိုင်သောကြောင့် title ကို Nullable (String?) အဖြစ်ထားပါ
  final String? title;
  // 💡 [REQUESTED]: Duration ကို Non-nullable (String) အဖြစ်ထားပါ
  final String? totalDurationHours;
  final String? price;
  // 💡 [FIX 1]: description ကိုလည်း Nullable (String?) အဖြစ်ထားပါ (API က null ပေးနိုင်သောကြောင့်)
  final String? description;
  final bool isPublished;
  final int studentCount;
  final int? durationDays;
  final int color;

  Course({
    required this.id,
    this.title, // Nullable
    this.totalDurationHours, // Non-nullable
    this.durationDays,
    this.price, // Nullable
    this.description, // 💡 [FIX 2]: Nullable ဖြစ်သောကြောင့် required မလိုပါ
    required this.isPublished,
    this.studentCount = 0,
    required this.color,
  });

  // 💡 Factory Method to create a Course object from JSON data
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,

      // 1. Title: API မှ String သို့မဟုတ် null ကို လက်ခံပါ
      title: json['title'] as String?,

      // 2. Duration: Non-nullable ဖြစ်သောကြောင့် null ဖြစ်ပါက 'N/A' default ပေးပါ
      totalDurationHours: json['totalDurationHours'] as String? ?? '',

      durationDays: json['durationdays'] as int?,

      // 3. Price: double သို့ ပြောင်းလဲပြီး null ဖြစ်ပါက 0.0 ပေးပါ
      price: json['price'] as String?,

      // 4. Description: 💡 [FIX 3]: description ကို String? အဖြစ် တိုက်ရိုက်ယူပါ
      description: json['description'] as String?,

      // 5. isPublished: API မှ bool ကို ယူပြီး null ဖြစ်ပါက false ပေးပါ
      isPublished: json['is_published'] as bool? ?? false,

      // 6. studentCount: API မှ int ကို ယူပြီး null ဖြစ်ပါက 0 ပေးပါ
      studentCount: json['student_count'] as int? ?? 0,

      color: json['color'] as int? ?? 0xFF9C27B0,
    );
  }

  // 💡 Method to convert a Course object to JSON data for API (Create/Update)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'totalDurationHours': totalDurationHours,
      'durationDays': durationDays,
      'price': price,
      'description': description,
      'is_published': isPublished,
    };
  }
}
