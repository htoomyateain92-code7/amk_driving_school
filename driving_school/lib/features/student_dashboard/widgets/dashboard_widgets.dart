import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../auth/providers/auth_providers.dart';
import '../repository/dashboard_repository.dart';

// --- Reusable UI Components ---

class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    return userAsync.when(
      data: (user) => Text(
        'Welcome back, ${user?.username ?? 'Student'}!',
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class UpcomingSessionCard extends ConsumerWidget {
  const UpcomingSessionCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(myUpcomingSessionsProvider);
    return sessionsAsync.when(
      loading: () => const DashboardCard(
          child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const DashboardCard(
          child: Center(child: Text('Could not load sessions.'))),
      data: (sessions) {
        if (sessions.isEmpty) {
          return const DashboardCard(
              icon: Icons.calendar_today_outlined,
              child: ListTile(
                  title: Text('No Upcoming Sessions'),
                  subtitle: Text('You have no scheduled classes.')));
        }
        final nextSession = sessions.first;
        return DashboardCard(
          icon: Icons.calendar_today,
          iconColor: Colors.amber,
          child: ListTile(
            title: Text(
                'Next Class: ${DateFormat.yMMMd().format(nextSession.startDt.toLocal())}'),
            subtitle: Text(
                DateFormat.jm().format(nextSession.startDt.toLocal()),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white)),
          ),
        );
      },
    );
  }
}

class MyBookingsList extends ConsumerWidget {
  const MyBookingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider အမှန်ကို watch လုပ်ပါ
    final bookingsAsync = ref.watch(myBookingsProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Card(
              color: Colors.black26,
              child: ListTile(title: Text('You have no active bookings yet.')));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            // Data type က 'booking' ဖြစ်သွားပါပြီ
            final booking = bookings[index];

            // Status အလိုက် အရောင်ပြောင်းရန်
            Color statusColor = Colors.grey;
            if (booking.status == 'approved') {
              statusColor = Colors.green;
            } else if (booking.status == 'pending') {
              statusColor = Colors.orange;
            } else if (booking.status == 'rejected') {
              statusColor = Colors.red;
            }

            return Card(
              color: Colors.black.withOpacity(0.2),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                // Data ကို booking object ထဲကနေ မှန်ကန်စွာ ဆွဲထုတ်သုံးပါ
                title: Text(booking.course.title,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text('Instructor: ${booking.instructorName ?? "N/A"}',
                    style: const TextStyle(color: Colors.white70)),
                trailing: Chip(
                  label: Text(booking.status,
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                ),
                onTap: () {/* TODO: Navigate to the booking detail page */},
              ),
            );
          },
        );
      },
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  const DashboardCard(
      {super.key, required this.child, this.icon, this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: icon != null
            ? Row(children: [
                Icon(icon, size: 40, color: iconColor ?? Colors.white54),
                const SizedBox(width: 16),
                Expanded(child: child),
              ])
            : child,
      ),
    );
  }
}
