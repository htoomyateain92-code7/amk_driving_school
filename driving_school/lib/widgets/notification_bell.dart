import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/notif_state.dart';
import '../theme/app_theme.dart';

final notifProvider = ChangeNotifierProvider<NotifState>((_) => NotifState());

class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});
  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  final _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notifProvider).seedDemo()); // demo data
  }

  @override
  Widget build(BuildContext context) {
    final notifs = ref.watch(notifProvider);
    final unread = notifs.unreadCount;

    return PopupMenuButton<String>(
      key: _menuKey,
      tooltip: 'Notifications',
      offset: const Offset(0, 12),
      color: Colors.black.withOpacity(.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (ctx) {
        final items = <PopupMenuEntry<String>>[];
        if (notifs.items.isEmpty) {
          items.add(
            const PopupMenuItem(
              value: '__none__',
              enabled: false,
              child: Text('No notifications'),
            ),
          );
        } else {
          for (final n in notifs.items.take(6)) {
            items.add(
              PopupMenuItem(
                value: n.id,
                child: Row(
                  children: [
                    if (!n.read)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.brightness_1,
                          size: 8,
                          color: Colors.redAccent,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            n.body,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem(
              value: '__all__',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.done_all, size: 18),
                  SizedBox(width: 8),
                  Text('Mark all read'),
                ],
              ),
            ),
          );
        }
        return items;
      },
      onSelected: (val) {
        if (val == '__all__') {
          ref.read(notifProvider).markAllRead();
        } else if (val != '__none__') {
          ref.read(notifProvider).markRead(val);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none, size: 26),
          if (unread > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
