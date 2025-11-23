import 'dart:math';
import '../models/models.dart';

final rnd = Random(42);

final List<Map<String, Object?>> _vehicleSeedData = [
  {
    'id': 'V-001',
    'driver': 'Alice',
    'plate': 'ESC 001',
    'note': 'Hello World XD',
    'market': [
      {'name': 'Onion', 'received': true},
      {'name': 'Garlic', 'received': false},
      {'name': 'Mushroom', 'received': false},
      {'name': 'Porkchop', 'received': true},
    ],
  },
  {
    'id': 'V-002',
    'driver': 'Bob',
    'plate': 'KOS 001',
    'note': 'Hello World XD',
    'market': [
      {'name': 'Carrot', 'received': true},
      {'name': 'Potato', 'received': true},
      {'name': 'Tomato', 'received': false},
      {'name': 'Spinach', 'received': false},
    ],
  },
  {
    'id': 'V-003',
    'driver': 'Charlie',
    'plate': 'ESC 002',
    'note': 'Hello World XD',
    'market': [
      {'name': 'Cabbage', 'received': false},
      {'name': 'Chicken Breast', 'received': true},
      {'name': 'Pepper', 'received': false},
    ],
  },
  {
    'id': 'V-004',
    'driver': 'Diana',
    'plate': 'KOS 002',
    'note': 'Hello World XD',
    'market': [
      {'name': 'Rice', 'received': true},
      {'name': 'Fish Sauce', 'received': true},
      {'name': 'Chili', 'received': true},
    ],
  },
];

List<Vehicle> mockVehicles() {
  return _vehicleSeedData
      .map((seed) => Vehicle(
        id: seed['id'] as String,
        driver: seed['driver'] as String,
        plate: seed['plate'] as String,
        note: seed['note'] as String,
            status: ['moving', 'idle', 'offline'][rnd.nextInt(3)],
            lat: 37.77 + rnd.nextDouble() * 0.05,
            lng: -122.42 + rnd.nextDouble() * 0.05,
            speedKph: rnd.nextDouble() * 80,
            fuelEfficiency: 8 + rnd.nextDouble() * 6,
          ))
      .toList();
}

List<FleetAlert> mockAlerts() {
  final types = ['speeding', 'idle', 'maintenance'];
  return List.generate(
    8,
    (i) => FleetAlert(
      id: 'A-$i',
      type: types[rnd.nextInt(types.length)],
      message: 'Alert message #$i',
      time: DateTime.now().subtract(Duration(minutes: i * 7)),
    ),
  );
}

List<Trip> mockTrips() {
  return List.generate(12, (i) {
    final start = DateTime.now().subtract(Duration(days: i + 1));
    final end = start.add(Duration(hours: 3 + rnd.nextInt(5)));
    final dist = 50 + rnd.nextDouble() * 120;
    final fuel = dist / (8 + rnd.nextDouble() * 6);
    final profit = 100 + rnd.nextDouble() * 400;
    final curr = rnd.nextInt(5);
    final all = curr + rnd.nextInt(5);
    return Trip(
      id: 'T-$i',
      start: start,
      end: end,
      distanceKm: dist,
      fuelUsedL: fuel,
      profit: profit,
      curr: curr,
      all: all,
    );
  });
}

List<MarketItem> mockMarketList(String vehicleId) {
  final vehicleSeed = _vehicleSeedData.firstWhere(
    (seed) => seed['id'] == vehicleId,
    orElse: () => _vehicleSeedData.first,
  );

  final items = vehicleSeed['market'] as List<Map<String, Object?>>? ?? const <Map<String, Object?>>[];

  return List.generate(items.length, (index) {
    final entry = items[index];
    return MarketItem(
      number: index + 1,
      name: entry['name'] as String,
      received: entry['received'] as bool,
    );
  });
}
