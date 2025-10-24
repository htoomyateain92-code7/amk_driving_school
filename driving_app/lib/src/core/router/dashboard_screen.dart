import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch student's bookings, quiz history, etc.

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        // TODO: Add a logout button
      ),
      body: const Center(
        child: Text(
          'Welcome! Your bookings and progress will appear here.',
        ),
      ),
    );
  }
}
