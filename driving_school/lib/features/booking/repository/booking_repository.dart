import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../models/session_model.dart';

class BookingRepository {
  // ApiClient ကို DI (Dependency Injection) သုံးပြီး ယူတာက ပိုကောင်းပေမယ့် လောလောဆယ် ဒီလိုပဲသုံးပါမယ်
  final _apiClient = ApiClient();

  /// Fetches all available (non-booked) sessions for a given batch.
  Future<List<Session>> fetchAvailableSessions(int batchId) async {
    final response =
        await _apiClient.dio.get('/api/v1/batches/$batchId/available-slots/');
    return (response.data as List)
        .map((json) => Session.fromJson(json))
        .toList();
  }

  /// Creates a new booking request with the selected course and session IDs.
  Future<void> createBooking(
      {required int courseId, required List<int> sessionIds}) async {
    await _apiClient.dio.post('/api/v1/bookings/', data: {
      'course': courseId,
      'sessions': sessionIds,
    });
  }
}

// BookingRepository instance တစ်ခုကို app တစ်ခုလုံးမှာ သုံးနိုင်အောင် provider ဖန်တီးပါ
final bookingRepositoryProvider = Provider((ref) => BookingRepository());
