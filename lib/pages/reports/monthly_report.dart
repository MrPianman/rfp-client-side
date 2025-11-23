import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/chart_palette.dart';

class MonthlyReport extends StatelessWidget {
  const MonthlyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        _VehicleSeriesChart(),
        const SizedBox(height: 12),
        _ProfitTrendChart(),
        const SizedBox(height: 12),
        _FuelDistributionChart(),
        const SizedBox(height: 12),
        _DriverRankingChart(),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _VehicleSeriesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vehicles = mockVehicles();
    final colors = seriesColors(context, vehicles.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle performance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (v, m) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final idx = v.toInt();
                          if (idx >= 0 && idx < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(months[idx], style: const TextStyle(fontSize: 11)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    for (final entry in vehicles.asMap().entries)
                      LineChartBarData(
                        isCurved: true,
                        color: colors[entry.key],
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        spots: List.generate(12, (i) => FlSpot(i.toDouble(), (i * 5 + (entry.key + 1) * 15).toDouble())),
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (items) => [
                        for (final it in items)
                          LineTooltipItem(
                            '${vehicles[it.barIndex].id}: ${it.y.toStringAsFixed(1)}',
                            TextStyle(color: colors[it.barIndex], fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final entry in vehicles.asMap().entries)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: CircleAvatar(backgroundColor: colors[entry.key], radius: 6),
                    label: Text(entry.value.id, style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfitTrendChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profit trend', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (v, m) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final idx = v.toInt();
                          if (idx >= 0 && idx < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(months[idx], style: const TextStyle(fontSize: 11)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, m) => Text('\$${v.toInt()}k', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      spots: List.generate(12, (i) => FlSpot(i.toDouble(), 5 + i * 2.5 + (i % 3) * 1.5)),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FuelDistributionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vehicles = mockVehicles();
    final colors = seriesColors(context, vehicles.length);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fuel distribution', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          for (final entry in vehicles.asMap().entries)
                            PieChartSectionData(
                              value: 20 + entry.key * 5,
                              title: '${(20 + entry.key * 5).toInt()}%',
                              color: colors[entry.key],
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in vehicles.asMap().entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[entry.key],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(entry.value.id, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverRankingChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vehicles = mockVehicles();
    final colors = seriesColors(context, vehicles.length);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver ranking', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < vehicles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(vehicles[idx].id, style: const TextStyle(fontSize: 11)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (final entry in vehicles.asMap().entries)
                      BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: 80 + entry.key * 25,
                            color: colors[entry.key],
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
