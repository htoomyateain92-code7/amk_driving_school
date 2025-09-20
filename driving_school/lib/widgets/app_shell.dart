import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'notification_bell.dart';
import 'user_menu.dart';

class AppShell extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  const AppShell({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar ?? _DefaultAppBar(),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

class _DefaultAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _DefaultAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('AMK Driving School'),
      actions: const [
        Padding(padding: EdgeInsets.only(right: 8), child: NotificationBell()),
        Padding(padding: EdgeInsets.only(right: 12), child: UserMenu()),
      ],
    );
  }
}
