// lib/models/course_model.dart

class Course {
  final int id;
  final String title; // "အခြေခံ ကားမောင်းသင်တန်း"
  final String duration; // "၁၀ ရက်"
  final double price; // 100000.0 (ကျပ်)
  final String description; // (Optional: အသေးစိတ်ဖော်ပြချက်)

  Course({
    required this.id,
    required this.title,
    required this.duration,
    required this.price,
    this.description = '',
  });

  // 💡 Factory Method to create a Course object from JSON data
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] as String,
      duration: json['duration'] as String,
      // price သည် String သို့မဟုတ် int/double အဖြစ် ပြန်လာနိုင်သည်ဟု ယူဆပါက
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      description: json['description'] as String? ?? '',
    );
  }
}
