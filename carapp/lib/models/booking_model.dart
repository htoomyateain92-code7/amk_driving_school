// lib/models/booking_model.dart

import 'session_model.dart';
// Booking တွင် Session အများအပြား ပါဝင်နိုင်သည်

class Booking {
  final int id;
  final String courseTitle; // ဘယ်သင်တန်းအတွက်လဲ
  final String bookingDate; // Booking လုပ်သည့်နေ့
  final String status; // Pending, Confirmed, Cancelled
  final String totalPrice;
  final List<Session> bookedSessions; // Booking လုပ်ထားသည့် Session များ

  Booking({
    required this.id,
    required this.courseTitle,
    required this.bookingDate,
    required this.status,
    required this.totalPrice,
    required this.bookedSessions,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Session list ကို parse လုပ်သည်
    final List<dynamic> sessionListJson = json['booked_sessions'] ?? [];
    final List<Session> sessions = sessionListJson
        .map((s) => Session.fromJson(s as Map<String, dynamic>))
        .toList();

    return Booking(
      id: json['id'] as int,
      courseTitle: json['course_title'] as String,
      bookingDate: json['booking_date'] as String, // Format: YYYY-MM-DD
      status: json['status'] as String,
      totalPrice: json['total_price'] as String,
      bookedSessions: sessions,
    );
  }
}
