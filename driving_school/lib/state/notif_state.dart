import 'package:flutter/material.dart';

class NotifItem {
  final String id;
  final String title;
  final String body;
  bool read;
  NotifItem({
    required this.id,
    required this.title,
    required this.body,
    this.read = false,
  });
}

class NotifState extends ChangeNotifier {
  final List<NotifItem> _items = [];

  List<NotifItem> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((e) => !e.read).length;

  // TODO: connect to backend later
  Future<void> seedDemo() async {
    if (_items.isEmpty) {
      _items.addAll([
        NotifItem(
          id: '1',
          title: 'Today’s Class',
          body: 'Batch A1 starts 16:00',
        ),
        NotifItem(
          id: '2',
          title: 'Completed',
          body: 'Yesterday session marked completed',
        ),
      ]);
      notifyListeners();
    }
  }

  void markRead(String id) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i != -1 && !_items[i].read) {
      _items[i].read = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (final n in _items) {
      n.read = true;
    }
    notifyListeners();
  }

  void add(NotifItem n) {
    _items.insert(0, n);
    notifyListeners();
  }
}
