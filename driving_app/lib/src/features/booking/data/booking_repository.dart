import 'package:dio/dio.dart';
import 'package:driving_app/src/core/api/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../courses/data/models/session_model.dart';

part 'booking_repository.g.dart';

class BookingRepository {
  final Dio _dio;
  BookingRepository(this._dio);

  // ดึง Session ทั้งหมดของ Batch ID ที่กำหนด
  Future<List<Session>> fetchAvailableSessions(int batchId) async {
    try {
      // Backend ของเราจะส่ง Session ทั้งหมดที่อยู่ใน Batch กลับมา
      final response = await _dio.get('/batches/$batchId/');
      final allSessions = (response.data['sessions'] as List)
          .map((s) => Session.fromJson(s))
          .toList();

      // คัดกรองเอาเฉพาะ Session ที่ยังว่างอยู่ (available)
      return allSessions.where((s) => s.status == 'available').toList();
    } on DioException catch (e) {
      throw e.response?.data['detail'] ?? 'Failed to fetch sessions';
    }
  }

  // สร้าง Booking ใหม่
  Future<void> createBooking({
    required int courseId,
    required List<int> sessionIds,
  }) async {
    try {
      await _dio.post(
        '/bookings/',
        data: {
          'course': courseId,
          'sessions': sessionIds,
        },
      );
    } on DioException catch (e) {
      // ส่ง error message ที่ได้จาก Django กลับไป
      final errorMessage =
          e.response?.data.toString() ?? 'Failed to create booking';
      throw errorMessage;
    }
  }
}

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(ref.watch(dioProvider));
}
