import 'package:flutter/material.dart';

import '../models/trip.dart';

class ProfitDetailsPage extends StatelessWidget {
  final List<Trip> trips;

  const ProfitDetailsPage({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalProfit = trips.fold<double>(0, (sum, trip) => sum + trip.profit);

    return Scaffold(
      appBar: AppBar(title: const Text('Profit Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Profit', style: theme.textTheme.titleMedium),
                    Text(
                      '\$${totalProfit.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Profit insights'),
                subtitle: const Text(
                  'High-profit trips (>250) receive a star so you can spot strong performers quickly.',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: trips.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
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
  }
}
