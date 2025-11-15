// lib/models/course_list_item_model.dart

// Course စာရင်းပြရန်အတွက် ပေါ့ပါးသော Model
class CourseListItem {
  final int id;
  final String title;
  final String price;
  final String description;
  final String? imageUrl; // ပုံစံအတွက် ထည့်ထားသည်

  CourseListItem({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    this.imageUrl,
  });

  factory CourseListItem.fromJson(Map<String, dynamic> json) {
    return CourseListItem(
      id: json['id'] as int,
      title: json['title'] as String,
      price: json['price'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}
