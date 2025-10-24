// lib/features/notifications/models/notification_model.dart

class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'],
    );
  }
}
