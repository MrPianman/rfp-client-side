import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/alert.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String? _filter; // speeding, idle, maintenance
  List<FleetAlert> _alerts = const [];

  @override
  void initState() {
    super.initState();
    _alerts = mockAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == null ? _alerts : _alerts.where((a) => a.type == _filter).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            children: [
              FilterChip(
                label: const Text('All', style: TextStyle(fontSize: 15)),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              for (final t in const ['speeding', 'idle', 'maintenance'])
                FilterChip(
                  label: Text(
                    t[0].toUpperCase() + t.substring(1),
                    style: const TextStyle(fontSize: 15),
                  ),
                  selected: _filter == t,
                  onSelected: (_) => setState(() => _filter = t),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              FilledButton.icon(
                onPressed: () => setState(() => _alerts = _alerts.map((a) => a.copyWith(read: true)).toList()),
                icon: const Icon(Icons.done_all, size: 22),
                label: const Text('Mark all read'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
            itemBuilder: (_, i) {
              final a = filtered[i];
              final isLight = Theme.of(context).brightness == Brightness.light;
              
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLight 
                        ? (a.read ? Colors.grey.shade200 : Colors.grey.shade100)
                        : (a.read ? Colors.grey : Theme.of(context).colorScheme.primary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    a.type == 'speeding'
                        ? Icons.speed
                        : a.type == 'idle'
                            ? Icons.pause_circle
                            : Icons.build,
                    color: a.read ? Colors.grey : Theme.of(context).colorScheme.primary,
                    size: Theme.of(context).iconTheme.size! * 1.3,
                  ),
                ),
                title: Text(
                  a.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    '${a.type[0].toUpperCase()}${a.type.substring(1)} • ${a.time.hour}:${a.time.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    a.read ? Icons.mark_email_read : Icons.mark_email_unread,
                    size: Theme.of(context).iconTheme.size! * 1.2,
                  ),
                  iconSize: Theme.of(context).iconTheme.size! * 1.2,
                  tooltip: a.read ? 'Mark unread' : 'Mark read',
                  onPressed: () => setState(() => _alerts = _alerts
                      .map((e) => e.id == a.id ? e.copyWith(read: !a.read) : e)
                      .toList()),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
