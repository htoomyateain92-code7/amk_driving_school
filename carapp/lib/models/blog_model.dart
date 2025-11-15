// lib/models/blog_model.dart

class Blog {
  final int id;
  final String title;
  final String content;
  final String authorName; // Author ၏ နာမည် (Read-only field)
  final bool isPublished;
  final DateTime publishedDate;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.isPublished,
    required this.publishedDate,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      // Django API က user_details.full_name မှ ပြန်ပေးမည်ဟု ယူဆသည်။
      authorName: json['author_name'] ?? 'Admin',
      isPublished: json['is_published'] ?? false,
      publishedDate: DateTime.parse(
        json['published_date'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'is_published': isPublished,
      // Create/Update အတွက် author_name ကို ပို့ရန်မလိုပါ။ Django က user ကို သိပါသည်။
    };
  }
}
