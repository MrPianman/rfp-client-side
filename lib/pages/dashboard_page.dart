import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../data/mock_data.dart';
import '../widgets/metric_card.dart';
import '../theme/chart_palette.dart';
import '../theme/theme_controller.dart';
import '../models/trip.dart';
import 'fleet_management_page.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToAlerts;
  
  const DashboardPage({super.key, this.onNavigateToAlerts});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentChartIndex = 0;
  final Set<int> _hiddenVehicleIndices = {};
  final Random _random = Random();

  String _generateTrend() {
    final value = _random.nextInt(30) + 1;
    final isPositive = _random.nextBool();
    return '${isPositive ? '+' : '-'}$value%';
  }

  bool _isTrendPositive(String trend, bool lowerIsBetter) {
    final isIncrease = trend.startsWith('+');
    return lowerIsBetter ? !isIncrease : isIncrease;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleVehicleVisibility(int index, int totalVehicles) {
    if (_hiddenVehicleIndices.contains(index)) {
      setState(() {
        _hiddenVehicleIndices.remove(index);
      });
    } else {
      if (_hiddenVehicleIndices.length < totalVehicles - 1) {
        setState(() {
          _hiddenVehicleIndices.add(index);
        });
      } else {
        _showCustomToast(context, 'At least one chip has to be shown');
      }
    }
  }

  void _showCustomToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear any existing snackbars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(
          bottom: 100,
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show Active Vehicles Details Dialog
  void _showVehicleDetails(BuildContext context, List vehicles) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.directions_car, color: Color(0xFFFF9800)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Vehicle Status',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                  '${vehicles.where((v) => v.status == 'moving').length} Active / ${vehicles.length} Total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'View real-time status of all vehicles in your fleet. Green indicates active/moving, orange for idle, and red for stopped.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.schedule, color: Color(0xFF2196F3)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delivery Times',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Track delivery times for each trip. Faster deliveries improve customer satisfaction and allow more trips per day.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
                      final duration = trip.end.difference(trip.start).inMinutes;
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
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
                        subtitle: Text('${trip.distanceKm.toStringAsFixed(1)} km'),
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
  void _showFuelEfficiencyDetails(BuildContext context, List vehicles, List trips) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_gas_station, color: Color(0xFF00BCD4)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Fuel Efficiency',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyan.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.cyan[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Monitor fuel consumption efficiency (km/L) for each trip. Green indicates good efficiency (>8 km/L), orange needs attention.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
                        subtitle: Text('${trip.distanceKm.toStringAsFixed(1)} km / ${trip.fuelUsedL.toStringAsFixed(1)} L'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${efficiency.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isEfficient ? Colors.green : Colors.orange,
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
  void _showProfitDetails(BuildContext context, List trips) {
    final totalProfit = trips.map((t) => t.profit).fold<double>(0, (a, b) => a + b);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.trending_up, color: Color(0xFF4CAF50)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Profit Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Profit',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '\$${totalProfit.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Profit by trip',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Track profit for each trip. High-profit trips (>250) are marked with a star. Focus on optimizing routes to maximize profits.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
                      final isHighProfit = trip.profit > 250;
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isHighProfit
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isHighProfit ? Icons.star : Icons.delivery_dining,
                            color: isHighProfit ? Colors.green : Colors.blue,
                          ),
                        ),
                        title: Text(
                          trip.id,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${trip.distanceKm.toStringAsFixed(1)} km'),
                        trailing: Text(
                          '\$${trip.profit.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isHighProfit ? Colors.green : Colors.grey[700],
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

  @override
  Widget build(BuildContext context) {
    final vehicles = mockVehicles();
    final alerts = mockAlerts();
    final trips = mockTrips();

    final controller = ThemeController.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller.dashboardChartLimit,
        controller.chartTripsTarget,
        controller.chartProfitTarget,
      ]),
      builder: (context, _) {
        final int dayWindow = controller.dashboardChartLimit.value.clamp(3, 30);
        final double tripsTarget = controller.chartTripsTarget.value.toDouble();
        final double profitTarget = controller.chartProfitTarget.value.toDouble();
        final active = vehicles.where((v) => v.status == 'moving').length;
        final avgTime = (trips
                    .map((t) => t.end.difference(t.start).inMinutes)
                    .fold<int>(0, (a, b) => a + b) /
                trips.length)
            .round();
        final avgFuelEff = (trips.map((t) => t.distanceKm / t.fuelUsedL).fold<double>(0, (a, b) => a + b) / trips.length)
            .toStringAsFixed(1);
        final profitToday = trips
            .take(3)
            .map((t) => t.profit)
            .fold<double>(0, (a, b) => a + b)
            .toStringAsFixed(0);

        final vehiclesTrend = _generateTrend();
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
                        trend: "$vehiclesTrend from last week",
                        isPositiveTrend: _isTrendPositive(vehiclesTrend, false),
                        onTap: () => _showVehicleDetails(context, vehicles),
                      ),
                  MetricCard(
                    title: 'Average Delivery Time',
                    value: avgTime.toString(),
                    icon: Icons.schedule,
                    color: const Color(0xFF2196F3), // Blue
                    subtitle: 'Minutes avg',
                    trend: '$timeTrend from last week',
                    isPositiveTrend: _isTrendPositive(timeTrend, true), // Lower is better
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
                    onTap: () => _showFuelEfficiencyDetails(context, vehicles, trips),
                  ),
                  MetricCard(
                    title: 'Profit Today',
                    value: '\$$profitToday',
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
              _TopVehiclesCard(trips: trips),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart Header with Title
                      Text(
                        _getChartTitle(_currentChartIndex),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Swipe instruction text
                      Text(
                        '← Swipe to change chart →',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentChartIndex = index);
                          },
                          clipBehavior: Clip.none,
                          padEnds: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 16),
                              child: _buildDotChart(context, vehicles, dayWindow),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 16),
                              child: _buildLineChart(context, vehicles, dayWindow, tripsTarget),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 16),
                              child: _buildFuelBarChart(context, vehicles),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 16),
                              child: _buildProfitBarChart(context, vehicles, profitTarget),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Page indicators (dots) - moved to bottom
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            4,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentChartIndex == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42, // Fixed height for chips
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final entry in vehicles.asMap().entries) ...[
                                GestureDetector(
                                  onTap: () => _toggleVehicleVisibility(entry.key, vehicles.length),
                                  child: _LegendChip(
                                    label: entry.value.id,
                                    color: seriesColors(context, vehicles.length)[entry.key],
                                    isHidden: _hiddenVehicleIndices.contains(entry.key),
                                  ),
                                ),
                                if (entry.key < vehicles.length - 1)
                                  const SizedBox(width: 12),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.1 : 0.08),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FleetManagementPage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.2 : 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.business_center,
                                color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage Vehicles & Drivers',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFCBCBCB) : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add & manage vehicles and drivers',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark ? Colors.grey[600] : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: isDark ? const Color(0xFFCFD0E3) : const Color(0xFF6B7280),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent alerts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: widget.onNavigateToAlerts,
                    icon: Icon(Icons.arrow_forward, size: Theme.of(context).textTheme.labelLarge?.fontSize),
                    label: Text('View All', style: Theme.of(context).textTheme.labelLarge),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(
                alerts.take(3).length,
                (i) {
                  final a = alerts[i];
                  final color = a.type == 'speeding'
                      ? Colors.red
                      : a.type == 'idle'
                          ? Colors.orange
                          : Colors.blue;
                  final isLight = Theme.of(context).brightness == Brightness.light;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isLight ? Colors.grey.shade100 : color.withValues(alpha: 0.15),
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
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: Theme.of(context).iconTheme.size,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
            );
          },
        );
      },
    );
  }

  String _getChartTitle(int index) {
    switch (index) {
      case 0:
        return 'Average Fuel Consumption (L per week)';
      case 1:
        return 'Average Speed (km per hour)';
      case 2:
        return 'Average Trips Completed (Trips per week)';
      case 3:
        return 'Average Profit (\$ per week)';
      default:
        return 'Average Fuel Consumption (L per week)';
    }
  }

  // Chart 1: Daily Trips Completed - Dot Chart (Scatter Plot)
  Widget _buildDotChart(BuildContext context, List vehicles, int dayWindow) {
    // Generate all data points for visible vehicles
    final allSpots = <FlSpot>[];
    for (final entry in vehicles.asMap().entries) {
      if (!_hiddenVehicleIndices.contains(entry.key)) {
        for (int i = 0; i < dayWindow; i++){
          allSpots.add(FlSpot(
            i.toDouble(),
            (i * 1.0 + (entry.key + 1) * 2).toDouble(),
          ));
        }
      }
    }
    
    // Calculate min/max from actual data
    final minY = allSpots.isEmpty ? 0 : allSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = allSpots.isEmpty ? 20 : allSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1; // 10% padding
    
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (dayWindow - 1).toDouble(),
        minY: (minY - padding).clamp(0, double.infinity),
        maxY: maxY + padding,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
                interval: dayWindow <= 12 ? 2 : 4,
              getTitlesWidget: (v, m) => Text(
                'D${v.toInt()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: ((maxY + padding) / 4).ceilToDouble(),
              getTitlesWidget: (v, m) => Text(
                v.toInt().toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          for (final entry in vehicles.asMap().entries)
            if (!_hiddenVehicleIndices.contains(entry.key))
              LineChartBarData(
                isCurved: false,
                color: seriesColors(context, vehicles.length)[entry.key],
                barWidth: 0, // No line, only dots
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 7, // Increased from 5 to 7 for better visibility
                      color: seriesColors(context, vehicles.length)[entry.key],
                      strokeWidth: 3, // Increased from 2 to 3
                      strokeColor: Colors.white,
                    );
                  },
                ),
                spots: List.generate(
                  dayWindow,
                  (i) => FlSpot(
                    i.toDouble(),
                    (i * 1.0 + (entry.key + 1) * 2).toDouble(),
                  ),
                ),
              ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surface,
            getTooltipItems: (items) => [
              for (final it in items)
                LineTooltipItem(
                  '${vehicles[it.barIndex].id}\n${it.y.toStringAsFixed(1)} L',
                  TextStyle(
                    color: seriesColors(context, vehicles.length)[it.barIndex],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          touchSpotThreshold: 20, // Increased touch area
        ),
      ),
    );
  }

  // Chart 2: Average Speed - Line Chart
  Widget _buildLineChart(BuildContext context, List vehicles, int dayWindow, double tripsTarget) {
    final allSpots = <FlSpot>[];
    for (final entry in vehicles.asMap().entries) {
      if (!_hiddenVehicleIndices.contains(entry.key)) {
        for (int i = 0; i < dayWindow; i++) {
          allSpots.add(FlSpot(
            i.toDouble(),
            (i * 1.0 + (entry.key + 1) * 2 + 20).toDouble(),
          ));
        }
      }
    }

    final minY = allSpots.isEmpty ? 20 : allSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = allSpots.isEmpty ? 38 : allSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.05;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (dayWindow - 1).toDouble(),
        minY: minY - padding,
        maxY: maxY + padding,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: dayWindow <= 12 ? 2 : 4,
              getTitlesWidget: (v, m) => Text(
                'D${v.toInt()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: ((maxY - minY + 2 * padding) / 4).ceilToDouble(),
              getTitlesWidget: (v, m) => Text(
                v.toInt().toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: true),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: tripsTarget,
              color: Colors.red,
              strokeWidth: 2,
              dashArray: [8, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 8, bottom: 4),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                labelResolver: (line) => 'Min Target: ${line.y.toInt()} trips',
              ),
            ),
          ],
        ),
        lineBarsData: [
          for (final entry in vehicles.asMap().entries)
            if (!_hiddenVehicleIndices.contains(entry.key))
              LineChartBarData(
                isCurved: true,
                color: seriesColors(context, vehicles.length)[entry.key],
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: seriesColors(context, vehicles.length)[entry.key],
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                spots: List.generate(
                  dayWindow,
                  (i) => FlSpot(
                    i.toDouble(),
                    (i * 1.0 + (entry.key + 1) * 2 + 20).toDouble(),
                  ),
                ),
              ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surface,
            getTooltipItems: (items) => [
              for (final it in items)
                LineTooltipItem(
                  '${vehicles[it.barIndex].id}\n${it.y.toStringAsFixed(1)} km/h',
                  TextStyle(
                    color: seriesColors(context, vehicles.length)[it.barIndex],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          touchSpotThreshold: 20,
        ),
      ),
    );
  }

  // Chart 3: Fuel Consumption - Bar Chart
  Widget _buildFuelBarChart(BuildContext context, List vehicles) {
    // Calculate all bar values for visible vehicles
    final allValues = <double>[];
    for (final entry in vehicles.asMap().entries) {
      if (!_hiddenVehicleIndices.contains(entry.key)) {
        allValues.add((entry.key + 1) * 15.0 + 20);
      }
    }
    
    // Calculate min/max from actual data
    final maxY = allValues.isEmpty ? 80 : allValues.reduce((a, b) => a > b ? a : b);
    final padding = maxY * 0.15; // 15% padding for bar charts
    
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY + padding,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, m) {
                if (v.toInt() >= vehicles.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    vehicles[v.toInt()].id,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: ((maxY + padding) / 4).ceilToDouble(),
              getTitlesWidget: (v, m) => Text(
                v.toInt().toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: true),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (final entry in vehicles.asMap().entries)
            if (!_hiddenVehicleIndices.contains(entry.key))
              BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: (entry.key + 1) * 15.0 + 20,
                    color: seriesColors(context, vehicles.length)[entry.key],
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (group) => Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${vehicles[group.x].id}\n${rod.toY.toStringAsFixed(1)} trips',
                TextStyle(
                  color: rod.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Chart 4: Daily Profit - Bar Chart
  Widget _buildProfitBarChart(BuildContext context, List vehicles, double profitTarget) {
    // Calculate all bar values for visible vehicles
    final allValues = <double>[];
    for (final entry in vehicles.asMap().entries) {
      if (!_hiddenVehicleIndices.contains(entry.key)) {
        allValues.add((entry.key + 1) * 150.0 + 300);
      }
    }
    
    // Calculate min/max from actual data
    final maxY = allValues.isEmpty ? 1000 : allValues.reduce((a, b) => a > b ? a : b);
    final padding = maxY * 0.15; // 15% padding for bar charts
    
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY + padding,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, m) {
                if (v.toInt() >= vehicles.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    vehicles[v.toInt()].id,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: ((maxY + padding) / 4).ceilToDouble(),
              getTitlesWidget: (v, m) => Text(
                '\$${v.toInt()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: true),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: profitTarget, // Minimum profit target line
              color: Colors.red,
              strokeWidth: 2,
              dashArray: [8, 4], // Dashed line
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 8, bottom: 4),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                labelResolver: (line) => 'Min Target: \$${line.y.toInt()}',
              ),
            ),
          ],
        ),
        barGroups: [
          for (final entry in vehicles.asMap().entries)
            if (!_hiddenVehicleIndices.contains(entry.key))
              BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: (entry.key + 1) * 150.0 + 300,
                    color: seriesColors(context, vehicles.length)[entry.key],
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (group) => Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${vehicles[group.x].id}\n\$${rod.toY.toStringAsFixed(0)}',
                TextStyle(
                  color: rod.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isHidden;
  
  const _LegendChip({
    required this.label, 
    required this.color, 
    this.isHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGrandmaMode = ThemeController.instance.grandmaMode.value;
    
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: CircleAvatar(
        backgroundColor: isHidden 
            ? Colors.grey.withValues(alpha: 0.3) 
            : color,
        radius: isGrandmaMode ? 8 : 6,
      ),
      label: Text(
        label,
        style: TextStyle(
          decoration: isHidden ? TextDecoration.lineThrough : null,
          color: isHidden ? Colors.grey : null,
          fontWeight: isGrandmaMode ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isHidden 
          ? Colors.grey.withValues(alpha: 0.1) 
          : (isGrandmaMode 
              ? color.withValues(alpha: 0.15)
              : null),
      side: isGrandmaMode 
          ? BorderSide(color: color, width: 2)
          : null,
    );
  }
}

class _TopVehiclesCard extends StatelessWidget {
  final List<Trip> trips;

  const _TopVehiclesCard({required this.trips});

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
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Based on current vs assigned trips',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < topThree.length; i++) ...[
              _TopVehicleRow(trip: topThree[i], rank: i + 1),
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

  const _TopVehicleRow({required this.trip, required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final double successRatio = trip.all == 0 ? 0 : trip.curr / trip.all;
    final double progress = successRatio.clamp(0, 1);
    final bool isCritical = successRatio <= 0.25;
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
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                      Icon(
                        Icons.error_outline,
                        color: scheme.error,
                        size: 16,
                      ),
                    if (isCritical) const SizedBox(width: 4),
                    Text(
                      '${(successRatio * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  'success',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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
            backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
            color: progressColor,
          ),
        ),
      ],
    );
  }
}
