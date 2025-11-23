import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/trip.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = mockTrips();
    final dailyStats = _statsFor(trips, const Duration(days: 1));
    final weeklyStats = _statsFor(trips, const Duration(days: 7));
    final monthlyStats = _statsFor(trips, const Duration(days: 30));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReportSummaryCard(
          title: 'Daily Mean',
          subtitle: 'Rolling 24h averages across the fleet',
          stats: dailyStats,
        ),
        const SizedBox(height: 16),
        _ReportSummaryCard(
          title: 'Weekly Mean',
          subtitle: 'Past 7 days',
          stats: weeklyStats,
        ),
        const SizedBox(height: 16),
        _ReportSummaryCard(
          title: 'Monthly Mean',
          subtitle: 'Past 30 days',
          stats: monthlyStats,
        ),
      ],
    );
  }

  _ReportStats _statsFor(List<Trip> trips, Duration range) {
    final now = DateTime.now();
    final scoped = trips.where((t) => t.start.isAfter(now.subtract(range))).toList();
    final data = scoped.isEmpty ? trips : scoped;
    return _ReportStats.fromTrips(data);
  }
}

class _ReportSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final _ReportStats stats;

  const _ReportSummaryCard({required this.title, required this.subtitle, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _SummaryMetric(
                  label: 'Trips Completed',
                  value: '${stats.completed.toStringAsFixed(1)} / ${stats.assigned.toStringAsFixed(1)}',
                  helper: 'avg per vehicle',
                ),
                _SummaryMetric(
                  label: 'Success Rate',
                  value: '${(stats.successRate * 100).clamp(0, 100).toStringAsFixed(1)}%',
                  helper: 'completed vs assigned',
                ),
                _SummaryMetric(
                  label: 'Avg Profit',
                    value: '\$${stats.profit.toStringAsFixed(0)}',
                  helper: 'per trip',
                ),
                _SummaryMetric(
                  label: 'Avg Distance',
                  value: '${stats.distance.toStringAsFixed(1)} km',
                  helper: 'per trip',
                ),
                _SummaryMetric(
                  label: 'Avg Fuel',
                  value: '${stats.fuel.toStringAsFixed(1)} L',
                  helper: 'per trip',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final String helper;

  const _SummaryMetric({required this.label, required this.value, required this.helper});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = (MediaQuery.sizeOf(context).width - 32 - 16) / 2;
    return SizedBox(
      width: width.clamp(200, double.infinity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            helper,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ReportStats {
  final double assigned;
  final double completed;
  final double profit;
  final double distance;
  final double fuel;

  const _ReportStats({
    required this.assigned,
    required this.completed,
    required this.profit,
    required this.distance,
    required this.fuel,
  });

  factory _ReportStats.fromTrips(List<Trip> trips) {
    if (trips.isEmpty) {
      return const _ReportStats(assigned: 0, completed: 0, profit: 0, distance: 0, fuel: 0);
    }

    double average(num Function(Trip) pick) {
      return trips.map((t) => pick(t).toDouble()).reduce((a, b) => a + b) / trips.length;
    }

    return _ReportStats(
      assigned: average((t) => t.all),
      completed: average((t) => t.curr),
      profit: average((t) => t.profit),
      distance: average((t) => t.distanceKm),
      fuel: average((t) => t.fuelUsedL),
    );
  }

  double get successRate => assigned == 0 ? 0 : completed / assigned;
}
