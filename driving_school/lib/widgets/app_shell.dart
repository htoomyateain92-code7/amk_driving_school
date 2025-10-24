import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notifications/screens/notification_screen.dart';
import 'side_menu_drawer.dart';

class AppShell extends ConsumerWidget {
  final Widget body;
  final String title;

  const AppShell({super.key, required this.body, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('0'), // TODO: Get unread count
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationScreen()));
            },
          ),
        ],
      ),
      drawer: const SideMenuDrawer(),
      body: body,
    );
  }
}
