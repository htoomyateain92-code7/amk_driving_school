import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../courses/models/course_model.dart';
import '../models/session_model.dart';
import '../providers/booking_provider.dart';

// Or wherever AuthWrapper/MainTabScreen is

class BookingScreen extends ConsumerStatefulWidget {
  final int batchId;
  final Course course;
  const BookingScreen({super.key, required this.batchId, required this.course});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(bookingNotifierProvider(widget.course).notifier)
          .fetchAvailableSessions(widget.batchId);
    });
  }

  // --- အချိန်ရွေးရန် Bottom Sheet ကိုပြသမည့် function ---
  void _showTimeSlotPicker(BuildContext context, List<Session> daySessions) {
    final bookingNotifier =
        ref.read(bookingNotifierProvider(widget.course).notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a Time Slot',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                itemCount: daySessions.length,
                itemBuilder: (context, index) {
                  final Session session = daySessions[index];
                  return ListTile(
                    leading: const Icon(Icons.access_time),
                    // `startTime` အစား `startDt` နှင့် `endDt` ကိုသုံးပါ
                    title: Text(
                        '${DateFormat.jm().format(session.startDt.toLocal())} - ${DateFormat.jm().format(session.endDt.toLocal())}'),
                    onTap: () {
                      bookingNotifier.toggleSessionSelection(session);
                      Navigator.pop(ctx);
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider(widget.course));
    final bookingNotifier =
        ref.read(bookingNotifierProvider(widget.course).notifier);

    // ... (ref.listen is the same)

    return Scaffold(
      appBar: AppBar(title: Text('Book for ${widget.course.title}')),
      body: bookingState.availableSessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error fetching sessions: $e")),
        data: (availableSessions) {
          return Column(
            children: [
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  final List<Session> daySessions = availableSessions
                      .where((s) =>
                          isSameDay(s.startDt.toLocal(), selectedDay) &&
                          s.status == 'available')
                      .toList();

                  if (daySessions.isNotEmpty) {
                    _showTimeSlotPicker(context, daySessions);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('No available time slots for this day.')));
                  }
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final isSelected = bookingState.selectedSessions
                        .any((s) => isSameDay(s.startDt.toLocal(), date));
                    if (isSelected) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.amber)),
                      );
                    }
                    return null;
                  },
                ),
              ),
              Expanded(
                  child: _buildSelectionSummary(bookingState, widget.course)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: bookingState.submissionStatus.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50)),
                        onPressed: bookingState.selectedSessions.isEmpty
                            ? null
                            : () => bookingNotifier.submitBooking(),
                        child: const Text('Submit Booking Request'),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectionSummary(BookingState bookingState, Course course) {
    if (bookingState.selectedSessions.isEmpty) {
      return const Center(
          child: Text('Please select a date from the calendar.',
              style: TextStyle(color: Colors.white70)));
    }

    double totalSelectedMinutes = bookingState.selectedSessions
        .fold(0, (sum, s) => sum + (s.endDt.difference(s.startDt).inMinutes));
    // double requiredMinutes = course.totalDurationHours * 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Selection:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              TextButton(
                onPressed: () => ref
                    .read(bookingNotifierProvider(course).notifier)
                    .clearSelection(),
                child: const Text('Clear All',
                    style: TextStyle(color: Colors.redAccent)),
              )
            ],
          ),
          const Divider(),
          ...bookingState.selectedSessions.map((s) => ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle, color: Colors.amber),
                title: Text(
                    DateFormat.yMMMd().add_jm().format(s.startDt.toLocal())),
              )),
          const Divider(),
          Text(
            'Total: ${(totalSelectedMinutes / 60).toStringAsFixed(1)} / ${course.totalDurationHours} hours',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
