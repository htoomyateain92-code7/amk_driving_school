// lib/features/auth/models/user_model.dart
class AppUser {
  final int id;
  final String username;
  final String email;
  final String role;
  final bool hasBookings; // <-- Field အသစ်ထပ်ထည့်ပါ

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.hasBookings, // <-- Constructor မှာထည့်ပါ
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'] ?? 'student',
      hasBookings: json['has_bookings'] ?? false, // <-- fromJson မှာထည့်ပါ
    );
  }
}
