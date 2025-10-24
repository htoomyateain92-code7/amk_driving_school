import 'package:driving_app/src/features/booking/presentation/booking_controller.dart';
// import 'package:driving_app/src/features/courses/data/models/session_model.dart';
import 'package:driving_app/src/features/courses/presentation/course_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({
    super.key,
    required this.courseId,
    required this.batchId,
  });
  final int courseId;
  final int batchId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  // Store selected session IDs
  final Set<int> _selectedSessionIds = {};

  @override
  Widget build(BuildContext context) {
    final courseAsync =
        ref.watch(courseDetailControllerProvider(widget.courseId));
    final sessionsAsync =
        ref.watch(availableSessionsControllerProvider(widget.batchId));
    final bookingState = ref.watch(bookingSubmitControllerProvider);

    ref.listen(bookingSubmitControllerProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking Failed: ${state.error}')),
        );
      }
      if (state is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Booking successful! Waiting for approval.')),
        );
        // Navigate to a "my bookings" screen or back to courses
        context.go('/courses');
      }
    });

    return courseAsync.when(
        data: (course) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book Your Sessions')),
            body: sessionsAsync.when(
              data: (sessions) {
                // Get required duration directly from the course model
                final requiredDurationHours = course.totalDurationHours;

                // Calculate total duration of selected sessions
                final selectedDurationMinutes = sessions
                    .where((s) => _selectedSessionIds.contains(s.id))
                    .fold<double>(
                        0.0,
                        (prev, s) =>
                            prev + s.endDt.difference(s.startDt).inMinutes);

                final isDurationMet =
                    (selectedDurationMinutes / 60) >= requiredDurationHours;

                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Course: ${course.title}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Required Duration: ${requiredDurationHours.toStringAsFixed(1)} hours',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Selected Duration: ${(selectedDurationMinutes / 60).toStringAsFixed(1)} hours',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: isDurationMet
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isSelected =
                            _selectedSessionIds.contains(session.id);
                        return CheckboxListTile(
                          title: Text(
                              DateFormat('EEE, MMM d').format(session.startDt)),
                          subtitle: Text(
                            '${DateFormat.jm().format(session.startDt)} - ${DateFormat.jm().format(session.endDt)}',
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedSessionIds.add(session.id);
                              } else {
                                _selectedSessionIds.remove(session.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ]);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  Center(child: Text('Error loading sessions: $e')),
            ),
            bottomNavigationBar: sessionsAsync.when(
              data: (sessions) {
                final requiredDurationHours = course.totalDurationHours;
                final selectedDurationMinutes = sessions
                    .where((s) => _selectedSessionIds.contains(s.id))
                    .fold<double>(
                        0.0,
                        (prev, s) =>
                            prev + s.endDt.difference(s.startDt).inMinutes);
                final isDurationMet =
                    (selectedDurationMinutes / 60) >= requiredDurationHours;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: (isDurationMet && !bookingState.isLoading)
                        ? () {
                            ref
                                .read(bookingSubmitControllerProvider.notifier)
                                .submitBooking(
                                  courseId: widget.courseId,
                                  sessionIds: _selectedSessionIds.toList(),
                                );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: bookingState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit Booking'),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
          );
        },
        loading: () => Scaffold(
            appBar: AppBar(title: const Text('Book Your Sessions')),
            body: const Center(child: CircularProgressIndicator())),
        error: (e, st) => Scaffold(
            appBar: AppBar(title: const Text('Book Your Sessions')),
            body: Center(child: Text('Error loading course: $e'))));
  }
}
