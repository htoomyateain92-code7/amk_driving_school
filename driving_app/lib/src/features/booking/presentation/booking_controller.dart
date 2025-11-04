import 'package:driving_app/src/features/booking/data/booking_repository.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../courses/data/models/session_model.dart';

part 'booking_controller.g.dart';

// 1. Controller สำหรับดึงข้อมูล Session ที่ว่างอยู่
@riverpod
class AvailableSessionsController extends _$AvailableSessionsController {
  @override
  FutureOr<List<SessionModel>> build(int batchId) {
    return ref.read(bookingRepositoryProvider).fetchAvailableSessions(batchId);
  }
}

// 2. Controller สำหรับจัดการตอนกด Submit Booking
@riverpod
class BookingSubmitController extends _$BookingSubmitController {
  @override
  FutureOr<void> build() {
    // ไม่ต้องทำอะไรตอนเริ่มต้น
  }

  Future<void> submitBooking({
    required int courseId,
    required List<int> sessionIds,
  }) async {
    final bookingRepository = ref.read(bookingRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => bookingRepository.createBooking(
          courseId: courseId, sessionIds: sessionIds),
    );
  }
}
