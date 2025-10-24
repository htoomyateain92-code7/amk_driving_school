import 'package:driving_school/features/student_dashboard/widgets/dashboard_widgets.dart';
import 'package:driving_school/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../booking/providers/booking_provider.dart';
import '../repository/dashboard_repository.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myUpcomingSessionsProvider);
        ref.invalidate(myBookingsProvider);
        ref.invalidate(userProfileProvider);
      },
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeHeader(),
            SizedBox(height: 24),
            ResponsiveLayout(
              mobileBody: StudentDashboardMobileLayout(),
              desktopBody: StudentDashboardDesktopLayout(),
            ),
          ],
        ),
      ),
    );
  }
}

// Mobile Screen Layout
class StudentDashboardMobileLayout extends StatelessWidget {
  const StudentDashboardMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next Session',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white70)),
        SizedBox(height: 12),
        UpcomingSessionCard(),
        SizedBox(height: 24),
        Text('My Bookings Courses',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white70)),
        SizedBox(height: 12),
        MyBookingsList(),
      ],
    );
  }
}

// Desktop/Tablet Screen Layout
class StudentDashboardDesktopLayout extends StatelessWidget {
  const StudentDashboardDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Enrolled Courses',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70)),
              SizedBox(height: 12),
              MyBookingsList(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Next Session',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70)),
              SizedBox(height: 12),
              UpcomingSessionCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class MyBookingsList extends ConsumerWidget {
  const MyBookingsList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (bookings) {
        if (bookings.isEmpty)
          return const Center(child: Text('You have no bookings yet.'));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(booking.course.title),
                subtitle: Text('Status: ${booking.status}'),
                trailing: Chip(label: Text(booking.status)),
              ),
            );
          },
        );
      },
    );
  }
}
