import 'package:flutter/material.dart';
import 'dart:math';
import '../data/mock_data.dart';
import '../widgets/metric_card.dart';
import '../theme/theme_controller.dart';
import '../models/trip.dart';
import 'profit_details_page.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToAlerts;

  const DashboardPage({super.key, this.onNavigateToAlerts});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Random _random = Random();

  String _generateTrend() {
    final value = _random.nextInt(30) + 1;
    final isPositive = _random.nextBool();
    return '${isPositive ? '+' : '-'}$value%';
  }

  bool _isTrendPositive(String trend, bool lowerIsBetter) {
    final trimmed = trend.trim();
    final isNegative = trimmed.startsWith('-');
    final isPositive = trimmed.startsWith('+');
    if (isNegative == isPositive) {
      // If the trend string lacks a sign, assume positive movement favors higher values.
      return !lowerIsBetter;
    }
    return lowerIsBetter ? isNegative : isPositive;
  }

  // Show Active Vehicles Details Dialog
  void _showVehicleDetails(BuildContext context, List vehicles) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF9800,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Vehicle Status',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "${vehicles.where((v) => v.status == 'moving').length} Active / ${vehicles.length} Total",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'View real-time status of all vehicles in your fleet. Green indicates active/moving, orange for idle, and red for stopped.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: vehicles.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      final isOnline = vehicle.status == 'moving';
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                        title: Text(
                          vehicle.id,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Driver: ${vehicle.driver}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? Colors.green.withValues(alpha: 0.1)
                                : vehicle.status == 'idle'
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? Colors.green
                                      : vehicle.status == 'idle'
                                      ? Colors.orange
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vehicle.status.toUpperCase(),
                                style: TextStyle(
                                  color: isOnline
                                      ? Colors.green
                                      : vehicle.status == 'idle'
                                      ? Colors.orange
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show Delivery Time Details Dialog
  void _showDeliveryTimeDetails(BuildContext context, List trips) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2196F3,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delivery Times',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Recent trip delivery times',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Track delivery times for each trip. Faster deliveries improve customer satisfaction and allow more trips per day.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: trips.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      final duration = trip.end
                          .difference(trip.start)
                          .inMinutes;
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2196F3,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delivery_dining,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        title: Text(
                          trip.id,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${trip.distanceKm.toStringAsFixed(1)} km',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$duration min',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${(trip.distanceKm / duration * 60).toStringAsFixed(1)} km/h',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show Fuel Efficiency Details Dialog
  void _showFuelEfficiencyDetails(
    BuildContext context,
    List vehicles,
    List trips,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF00BCD4,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_gas_station,
                            color: Color(0xFF00BCD4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Fuel Efficiency',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Fuel efficiency by trip',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.cyan.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.cyan[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Monitor fuel consumption efficiency (km/L) for each trip. Green indicates good efficiency (>8 km/L), orange needs attention.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: trips.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      final efficiency = trip.distanceKm / trip.fuelUsedL;
                      final isEfficient = efficiency > 8;
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isEfficient
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.local_gas_station,
                            color: isEfficient ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text(
                          trip.id,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${trip.distanceKm.toStringAsFixed(1)} km / ${trip.fuelUsedL.toStringAsFixed(1)} L',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${efficiency.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isEfficient
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            Text(
                              'km/L',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show Profit Details Dialog
  void _showProfitDetails(BuildContext context, List<Trip> trips) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfitDetailsPage(trips: List<Trip>.from(trips)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = mockVehicles();
    final alerts = mockAlerts();
    final trips = mockTrips();

    final controller = ThemeController.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller.normalTripSuccessPercent,
      ]),
      builder: (context, _) {
        final int normalTripPercent = controller.normalTripSuccessPercent.value;
        final active = vehicles.where((v) => v.status == 'moving').length;
        final avgTime =
            (trips
                        .map((t) => t.end.difference(t.start).inMinutes)
                        .fold<int>(0, (a, b) => a + b) /
                    trips.length)
                .round();
        final avgFuelEff =
            (trips
                        .map((t) => t.distanceKm / t.fuelUsedL)
                        .fold<double>(0, (a, b) => a + b) /
                    trips.length)
                .toStringAsFixed(1);
        final profitToday = trips
            .take(3)
            .map((t) => t.profit)
            .fold<double>(0, (a, b) => a + b)
            .toStringAsFixed(0);

        final timeTrend = _generateTrend();
        final fuelTrend = _generateTrend();
        final profitTrend = _generateTrend();

        return LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth > 700;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      MetricCard(
                        title: 'Active Vehicles',
                        value: active.toString(),
                        icon: Icons.directions_car,
                        color: const Color(0xFFFF9800),
                        subtitle: 'Out of ${vehicles.length} total',
                        onTap: () => _showVehicleDetails(context, vehicles),
                      ),
                      MetricCard(
                        title: 'Average Delivery Time',
                        value: '$avgTime minutes',
                        icon: Icons.schedule,
                        color: const Color(0xFF2196F3), // Blue
                        subtitle: 'Minutes avg',
                        trend: '$timeTrend from last week',
                        isPositiveTrend: _isTrendPositive(
                          timeTrend,
                          true,
                        ), // Lower is better
                        onTap: () => _showDeliveryTimeDetails(context, trips),
                      ),
                      MetricCard(
                        title: 'Fuel Efficiency',
                        value: avgFuelEff,
                        icon: Icons.local_gas_station,
                        color: const Color(0xFF00BCD4), // Cyan
                        subtitle: 'km/l average',
                        trend: '$fuelTrend from last week',
                        isPositiveTrend: _isTrendPositive(fuelTrend, false),
                        onTap: () => _showFuelEfficiencyDetails(
                          context,
                          vehicles,
                          trips,
                        ),
                      ),
                      MetricCard(
                        title: 'Profit Today',
                        value: '$profitToday THB',
                        icon: Icons.trending_up,
                        color: const Color(0xFF4CAF50), // Green
                        subtitle: 'Daily revenue',
                        trend: '$profitTrend from last week',
                        isPositiveTrend: _isTrendPositive(profitTrend, false),
                        onTap: () => _showProfitDetails(context, trips),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _TopVehiclesCard(
                    trips: trips,
                    normalTripPercent: normalTripPercent,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent alerts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onNavigateToAlerts,
                        icon: Icon(
                          Icons.arrow_forward,
                          size: Theme.of(
                            context,
                          ).textTheme.labelLarge?.fontSize,
                        ),
                        label: Text(
                          'View All',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(alerts.take(3).length, (i) {
                    final a = alerts[i];
                    final color = a.type == 'speeding'
                        ? Colors.red
                        : a.type == 'idle'
                        ? Colors.orange
                        : Colors.blue;
                    final isLight =
                        Theme.of(context).brightness == Brightness.light;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.grey.shade100
                                  : color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              a.type == 'speeding'
                                  ? Icons.speed
                                  : a.type == 'idle'
                                  ? Icons.pause_circle
                                  : Icons.build,
                              color: color,
                              size: Theme.of(context).iconTheme.size! * 1.3,
                            ),
                          ),
                          title: Text(
                            a.type.toUpperCase(),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              a.message,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            size: Theme.of(context).iconTheme.size,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

}

class _TopVehiclesCard extends StatelessWidget {
  final List<Trip> trips;
  final int normalTripPercent;

  const _TopVehiclesCard({
    required this.trips,
    required this.normalTripPercent,
  });

  @override
  Widget build(BuildContext context) {
    final topTrips = [...trips]..sort((a, b) => b.curr.compareTo(a.curr));
    final topThree = topTrips.take(3).toList();

    if (topThree.isEmpty) {
      return const SizedBox.shrink();
    }

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
              'Top Delivering Vehicles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Based on current vs assigned trips',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Normal success ≥ $normalTripPercent%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < topThree.length; i++) ...[
              _TopVehicleRow(
                trip: topThree[i],
                rank: i + 1,
                normalTripPercent: normalTripPercent,
              ),
              if (i < topThree.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopVehicleRow extends StatelessWidget {
  final Trip trip;
  final int rank;
  final int normalTripPercent;

  const _TopVehicleRow({
    required this.trip,
    required this.rank,
    required this.normalTripPercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final double successRatio = trip.all == 0 ? 0 : trip.curr / trip.all;
    final double progress = successRatio.clamp(0, 1);
    final bool isCritical =
        (successRatio * 100).clamp(0, 100).toDouble() < normalTripPercent;
    final Color progressColor = isCritical ? scheme.error : scheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$rank',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.id,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trip.curr} / ${trip.all} deliveries',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCritical)
                      Icon(Icons.error_outline, color: scheme.error, size: 16),
                    if (isCritical) const SizedBox(width: 4),
                    Text(
                      '${(successRatio * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'success',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (isCritical)
                  Text(
                    'Below $normalTripPercent% target → profit risk',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest.withValues(
              alpha: 0.6,
            ),
            color: progressColor,
          ),
        ),
      ],
    );
  }
}
