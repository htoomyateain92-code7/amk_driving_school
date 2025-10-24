// lib/features/notifications/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../repository/notification_repository.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('You have no notifications.'));
          }
          // Pull to refresh feature
          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? Colors.grey.withOpacity(0.5)
                        : Theme.of(context).primaryColor,
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                      '${notification.body}\n${DateFormat.yMMMd().add_jm().format(notification.createdAt.toLocal())}'),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Mark notification as read and navigate to detail if needed
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
