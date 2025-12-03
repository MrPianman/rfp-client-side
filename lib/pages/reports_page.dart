import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/trip.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedSectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final trips = mockTrips();
    final dailyStats = _statsFor(trips, const Duration(days: 1));
    final weeklyStats = _statsFor(trips, const Duration(days: 7));
    final monthlyStats = _statsFor(trips, const Duration(days: 30));

    final sections = [
      _MetroReportSection(
        title: 'Daily Mean',
        subtitle: 'Rolling 24h averages across the fleet',
        stats: dailyStats,
        tabLabel: 'Daily',
      ),
      _MetroReportSection(
        title: 'Weekly Mean',
        subtitle: 'Past 7 days snapshot',
        stats: weeklyStats,
        tabLabel: 'Weekly',
      ),
      _MetroReportSection(
        title: 'Monthly Mean',
        subtitle: 'Past 30 days performance',
        stats: monthlyStats,
        tabLabel: 'Monthly',
      ),
    ];

    final theme = Theme.of(context);
    final selectedIndex = _selectedSectionIndex.clamp(0, sections.length - 1);
    final selectedSection = sections[selectedIndex];

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedIndex,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  items: [
                    for (var i = 0; i < sections.length; i++)
                      DropdownMenuItem<int>(
                        value: i,
                        child: Text(sections[i].tabLabel),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedSectionIndex = value);
                  },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: 24),
            child: _MetroSection(section: selectedSection),
          ),
        ),
      ],
    );
  }

  _ReportStats _statsFor(List<Trip> trips, Duration range) {
    final now = DateTime.now();
    final scoped = trips
        .where((t) => t.start.isAfter(now.subtract(range)))
        .toList();
    final data = scoped.isEmpty ? trips : scoped;
    return _ReportStats.fromTrips(data);
  }
}

class _MetroReportSection {
  final String title;
  final String subtitle;
  final _ReportStats stats;
  final String tabLabel;

  const _MetroReportSection({
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.tabLabel,
  });
}

class _MetroSection extends StatelessWidget {
  final _MetroReportSection section;

  const _MetroSection({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = theme.colorScheme.onSurfaceVariant;
    final metrics = _metricsFor(section.stats);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.hasBoundedWidth && !constraints.biggest.isInfinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;

        if (availableWidth <= 360) {
          return _MetroColumnLayout(
            section: section,
            metrics: metrics,
            width: availableWidth,
          );
        }

        final rectangleMetrics = metrics.take(4).toList();
        final remaining = metrics.skip(4).toList();
        Color colorFor(int index) =>
            _metroTileColors[index % _metroTileColors.length];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              section.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: bodyColor),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rectangleMetrics.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final metric = rectangleMetrics[index];
                return _MetroTile(data: metric, color: colorFor(index));
              },
            ),
            if (remaining.isNotEmpty) const SizedBox(height: 16),
            for (var i = 0; i < remaining.length; i++) ...[
              AspectRatio(
                aspectRatio: 1.95,
                child: _MetroTile(
                  data: remaining[i],
                  color: colorFor(rectangleMetrics.length + i),
                ),
              ),
              if (i != remaining.length - 1) const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}

class _MetroColumnLayout extends StatelessWidget {
  final _MetroReportSection section;
  final List<_TileMetric> metrics;
  final double width;

  const _MetroColumnLayout({
    required this.section,
    required this.metrics,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          section.subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < metrics.length; i++) ...[
          _MetroTile(
            data: metrics[i],
            color: _metroTileColors[i % _metroTileColors.length],
            width: width,
            height: 140,
          ),
          if (i != metrics.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MetroTile extends StatelessWidget {
  final _TileMetric data;
  final Color color;
  final double? width;
  final double? height;

  const _MetroTile({
    required this.data,
    required this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : color.withValues(alpha: 0.35);

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 18),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              data.label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              data.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              data.helper,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (height != null) const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _TileMetric {
  final String label;
  final String value;
  final String helper;

  const _TileMetric({
    required this.label,
    required this.value,
    required this.helper,
  });
}

List<_TileMetric> _metricsFor(_ReportStats stats) {
  return [
    _TileMetric(
      label: 'Success Rate',
      value: '${(stats.successRate * 100).clamp(0, 100).toStringAsFixed(1)}%',
      helper: 'completed vs assigned',
    ),
    _TileMetric(
      label: 'Avg Profit',
      value: '\$${stats.profit.toStringAsFixed(0)}',
      helper: 'per trip',
    ),
    _TileMetric(
      label: 'Avg Distance',
      value: '${stats.distance.toStringAsFixed(1)} km',
      helper: 'per trip',
    ),
    _TileMetric(
      label: 'Avg Fuel',
      value: '${stats.fuel.toStringAsFixed(1)} L',
      helper: 'per trip',
    ),
    _TileMetric(
      label: 'Carbon Reduction',
      value:
          '${stats.carbonReductionKg > 0 ? '↓' : '↑'} ${stats.carbonReductionKg.abs().clamp(0, double.infinity).toStringAsFixed(1)} kg',
      helper: 'vs baseline emissions',
    ),
  ];
}

const List<Color> _metroTileColors = [
  Color(0xFF0078D7),
  Color(0xFF0099BC),
  Color(0xFF2D7D9A),
  Color(0xFF00B7C2),
  Color(0xFF5C2E91),
  Color(0xFFE81123),
  Color(0xFFF7630C),
];

class _ReportStats {
  final double assigned;
  final double completed;
  final double profit;
  final double distance;
  final double fuel;
  final double carbonReductionKg;

  const _ReportStats({
    required this.assigned,
    required this.completed,
    required this.profit,
    required this.distance,
    required this.fuel,
    required this.carbonReductionKg,
  });

  factory _ReportStats.fromTrips(List<Trip> trips) {
    if (trips.isEmpty) {
      return const _ReportStats(
        assigned: 0,
        completed: 0,
        profit: 0,
        distance: 0,
        fuel: 0,
        carbonReductionKg: 0,
      );
    }

    double average(num Function(Trip) pick) {
      return trips.map((t) => pick(t).toDouble()).reduce((a, b) => a + b) /
          trips.length;
    }

    const double baselineKgPerKm = 0.24;
    const double kgPerLiter = 2.31;
    final double totalReductionKg = trips.fold<double>(0, (sum, trip) {
      final baseline = trip.distanceKm * baselineKgPerKm;
      final actual = trip.fuelUsedL * kgPerLiter;
      final reduction = (baseline - actual).clamp(0, double.infinity);
      return sum + reduction;
    });

    return _ReportStats(
      assigned: average((t) => t.all),
      completed: average((t) => t.curr),
      profit: average((t) => t.profit),
      distance: average((t) => t.distanceKm),
      fuel: average((t) => t.fuelUsedL),
      carbonReductionKg: totalReductionKg,
    );
  }

  double get successRate => assigned == 0 ? 0 : completed / assigned;
}
