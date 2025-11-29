// lib/models/booking_model.dart

import 'session_model.dart';
// Booking တွင် Session အများအပြား ပါဝင်နိုင်သည်

class Booking {
  final int id;
  final String courseTitle; // ဘယ်သင်တန်းအတွက်လဲ
  final String? batchTitle;
  final int? batchId;
  final String? createdAt;
  // final String? bookingDate;
  final String status; // Pending, Confirmed, Cancelled
  final String totalPrice;
  final List<Session> bookedSessions; // Booking လုပ်ထားသည့် Session များ

  Booking({
    required this.id,
    required this.courseTitle,
    this.batchTitle,
    this.batchId, // Constructor တွင် ထည့်သွင်းပါ
    this.createdAt,
    // this.bookingDate,
    required this.status,
    required this.totalPrice,
    required this.bookedSessions,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? courseJson =
        json['course'] as Map<String, dynamic>?;

    // final Map<String, dynamic>? batchJson =
    //     json['batch'] as Map<String, dynamic>?;

    final List<dynamic> sessionListJson = json['booked_sessions'] ?? [];
    final List<Session> sessions = sessionListJson
        .map((s) => Session.fromJson(s as Map<String, dynamic>))
        .toList();

    int? finalBatchId;
    final dynamic batchData = json['batch'];
    if (batchData is int) {
      // Backend မှ ID (Integer) သာ ပို့သောအခါ
      finalBatchId = batchData;
    } else if (batchData is Map<String, dynamic>) {
      // Nested Object ပို့သောအခါ
      finalBatchId = batchData['id'] as int?;
    }

    return Booking(
      id: json['id'] as int,
      courseTitle: courseJson?['title'] as String? ?? 'N/A',
      batchId: finalBatchId,
      // batchTitle: json['batch_title'] as String?,
      createdAt: json['created_at'] as String?,
      status: json['status'] as String? ?? 'N/A',
      totalPrice: courseJson?['price'] as String? ?? 'N/A',
      bookedSessions: sessions,
    );
  }
}
