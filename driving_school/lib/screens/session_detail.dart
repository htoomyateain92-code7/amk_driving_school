// lib/screens/session_detail.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/session_repo.dart';

class SessionDetail extends StatefulWidget {
  final int id;
  const SessionDetail({super.key, required this.id});

  @override
  State<SessionDetail> createState() => _SessionDetailState();
}

class _SessionDetailState extends State<SessionDetail> {
  late Future<SessionDetailM> _future;
  final _fmt = DateFormat('EEE, MMM d • HH:mm');

  @override
  void initState() {
    super.initState();
    _future = SessionRepo().detail(widget.id);
  }

  Future<void> _markCompleted() async {
    try {
      await SessionRepo().markCompleted(widget.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Marked as completed')));
      setState(() => _future = SessionRepo().detail(widget.id)); // refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Detail')),
      body: FutureBuilder<SessionDetailM>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final s = snap.data!;
          final now = DateTime.now();
          final isUpcoming = now.isBefore(s.endDt);
          final statusColor =
              {
                'scheduled': Colors.blue,
                'completed': Colors.green,
                'canceled': Colors.red,
              }[s.status] ??
              Colors.grey;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.courseTitle ?? 'Session',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(s.status),
                      backgroundColor: statusColor.withOpacity(0.15),
                      labelStyle: TextStyle(color: statusColor),
                      side: BorderSide(color: statusColor),
                    ),
                    const SizedBox(width: 8),
                    Chip(label: Text(isUpcoming ? 'Upcoming' : 'Passed')),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(
                    '${_fmt.format(s.startDt.toLocal())} → ${_fmt.format(s.endDt.toLocal())}',
                  ),
                  subtitle: Text('Batch #${s.batch}'),
                ),
                if (s.reason != null && s.reason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Reason'),
                    subtitle: Text(s.reason!),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: s.status == 'completed'
                            ? null
                            : _markCompleted,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark Completed'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
