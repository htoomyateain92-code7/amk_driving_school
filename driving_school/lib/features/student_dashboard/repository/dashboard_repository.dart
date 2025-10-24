import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/models/session_model.dart';

class DashboardRepository {
  final _apiClient = ApiClient();

  Future<List<Booking>> fetchMyBookings() async {
    final response = await _apiClient.dio.get('/api/v1/bookings/');
    return (response.data as List)
        .map((json) => Booking.fromJson(json))
        .toList();
  }

  Future<List<Session>> fetchMyUpcomingSessions() async {
    final response = await _apiClient.dio.get('/api/v1/sessions/my-upcoming/');
    return (response.data as List)
        .map((json) => Session.fromJson(json))
        .toList();
  }
}

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

final myBookingsProvider = FutureProvider(
    (ref) => ref.watch(dashboardRepositoryProvider).fetchMyBookings());
final myUpcomingSessionsProvider = FutureProvider(
    (ref) => ref.watch(dashboardRepositoryProvider).fetchMyUpcomingSessions());
