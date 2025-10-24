import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../courses/models/course_model.dart';

import '../models/session_model.dart';
import '../repository/booking_repository.dart';

// Booking process ရဲ့ state အားလုံးကို ထိန်းသိမ်းရန်
@immutable
class BookingState {
  final AsyncValue<List<Session>> availableSessions;
  final int selectedSessionLengthMinutes;
  final List<Session> selectedSessions;
  final AsyncValue<void> submissionStatus;

  const BookingState({
    this.availableSessions = const AsyncLoading(),
    this.selectedSessionLengthMinutes = 60, // Default to 1 hour
    this.selectedSessions = const [],
    this.submissionStatus = const AsyncData(null),
  });

  BookingState copyWith({
    AsyncValue<List<Session>>? availableSessions,
    int? selectedSessionLengthMinutes,
    List<Session>? selectedSessions,
    AsyncValue<void>? submissionStatus,
  }) {
    return BookingState(
      availableSessions: availableSessions ?? this.availableSessions,
      selectedSessionLengthMinutes:
          selectedSessionLengthMinutes ?? this.selectedSessionLengthMinutes,
      selectedSessions: selectedSessions ?? this.selectedSessions,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}

// StateNotifier
class BookingNotifier extends StateNotifier<BookingState> {
  final Ref _ref;
  final Course _course;

  BookingNotifier(this._ref, this._course) : super(const BookingState());

  Future<void> fetchAvailableSessions(int batchId) async {
    state = state.copyWith(availableSessions: const AsyncLoading());
    try {
      final sessions = await _ref
          .read(bookingRepositoryProvider)
          .fetchAvailableSessions(batchId);
      state = state.copyWith(availableSessions: AsyncData(sessions));
    } catch (e, st) {
      state = state.copyWith(availableSessions: AsyncError(e, st));
    }
  }

  void selectSessionLength(int minutes) {
    state = state.copyWith(
        selectedSessionLengthMinutes: minutes,
        selectedSessions: []); // Reset selection
  }

  void toggleSessionSelection(Session session) {
    final isSelected = state.selectedSessions.any((s) => s.id == session.id);
    List<Session> newSelection = List.from(state.selectedSessions);

    if (isSelected) {
      newSelection.removeWhere((s) => s.id == session.id);
    } else {
      newSelection.add(session);
    }

    // Check if total selected duration exceeds course duration
    double totalSelectedMinutes = newSelection.fold(
        0, (sum, s) => sum + (s.endDt.difference(s.startDt).inMinutes));
    double requiredMinutes = _course.totalDurationHours * 60;

    if (totalSelectedMinutes > requiredMinutes) {
      // Optional: show a snackbar or some feedback to the user
      print("Cannot select more sessions. Duration limit reached.");
      return; // Do not update state
    }

    state = state.copyWith(selectedSessions: newSelection);
  }

  Future<void> submitBooking() async {
    state = state.copyWith(submissionStatus: const AsyncLoading());
    try {
      final sessionIds = state.selectedSessions.map((s) => s.id).toList();
      await _ref.read(bookingRepositoryProvider).createBooking(
            courseId: _course.id,
            sessionIds: sessionIds,
          );
      state = state.copyWith(submissionStatus: const AsyncData(null));
    } catch (e, st) {
      state = state.copyWith(submissionStatus: AsyncError(e, st));
    }
  }

  void clearSelection() {
    state = state.copyWith(selectedSessions: []);
  }
}

// Provider
final bookingNotifierProvider =
    StateNotifierProvider.family<BookingNotifier, BookingState, Course>(
        (ref, course) {
  return BookingNotifier(ref, course);
});
