import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

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
      .map(
        (seed) => Vehicle(
          id: seed['id'] as String,
          driver: seed['driver'] as String,
          plate: seed['plate'] as String,
          note: seed['note'] as String,
          status: ['moving', 'idle', 'offline'][rnd.nextInt(3)],
          lat: 37.77 + rnd.nextDouble() * 0.05,
          lng: -122.42 + rnd.nextDouble() * 0.05,
          speedKph: rnd.nextDouble() * 80,
          fuelEfficiency: 8 + rnd.nextDouble() * 6,
        ),
      )
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

  final items =
      vehicleSeed['market'] as List<Map<String, Object?>>? ??
      const <Map<String, Object?>>[];

  return List.generate(items.length, (index) {
    final entry = items[index];
    return MarketItem(
      number: index + 1,
      name: entry['name'] as String,
      received: entry['received'] as bool,
    );
  });
}

const String _vehicleByPropertiesQuery = r'''
  query VehicleByProperties($id: ID!, $driver: String!, $plate: String!, $note: String!) {
    vehicleByProperties(id: $id, driver: $driver, plate: $plate, note: $note) {
      id
      driver
      plate
      note
      status
      lat
      lng
      speedKph
      fuelEfficiency
    }
  }
''';

/// Calls a GraphQL endpoint with the provided Vehicle field values as variables.
/// Update the `_vehicleByPropertiesQuery` string if your backend exposes a different
/// operation name or shape. Returns `null` when the server does not match a vehicle.
Future<Vehicle?> fetchVehicleFromGraphQl({
  required Uri endpoint,
  required String id,
  required String driver,
  required String plate,
  required String note,
  http.Client? client,
}) async {
  final http.Client resolvedClient = client ?? http.Client();
  final body = jsonEncode({
    'query': _vehicleByPropertiesQuery,
    'variables': {'id': id, 'driver': driver, 'plate': plate, 'note': note},
  });

  try {
    final response = await resolvedClient.post(
      endpoint,
      headers: const {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'GraphQL request failed (${response.statusCode}): ${response.body}',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final errors = payload['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw Exception('GraphQL errors: $errors');
    }

    final data = payload['data'] as Map<String, dynamic>?;
    final vehicleData = data?['vehicleByProperties'] as Map<String, dynamic>?;
    if (vehicleData == null) {
      return null;
    }

    double _asDouble(dynamic source) {
      if (source is num) {
        return source.toDouble();
      }
      throw const FormatException('Expected numeric field in GraphQL response');
    }

    return Vehicle(
      id: vehicleData['id'] as String,
      driver: vehicleData['driver'] as String,
      plate: vehicleData['plate'] as String,
      note: (vehicleData['note'] as String?) ?? '',
      status: (vehicleData['status'] as String?) ?? 'offline',
      lat: _asDouble(vehicleData['lat']),
      lng: _asDouble(vehicleData['lng']),
      speedKph: _asDouble(vehicleData['speedKph']),
      fuelEfficiency: _asDouble(vehicleData['fuelEfficiency']),
    );
  } finally {
    if (client == null) {
      resolvedClient.close();
    }
  }
}

/// Convenience helper that iterates over the locally available vehicle seed data,
/// calls the GraphQL backend for each entry, and falls back to the mock values
/// when the server cannot satisfy the request. Throws when every request fails
/// so that the UI can surface the outage to the operator.
Future<List<Vehicle>> fetchVehiclesFromServer({
  required Uri endpoint,
  http.Client? client,
}) async {
  final http.Client resolvedClient = client ?? http.Client();
  final fallbackVehicles = mockVehicles();
  final seeds = _vehicleSeedData
      .map(
        (seed) => (
          id: seed['id'] as String,
          driver: seed['driver'] as String,
          plate: seed['plate'] as String,
          note: seed['note'] as String,
        ),
      )
      .toList(growable: false);

  final List<Vehicle> resolvedVehicles = <Vehicle>[];
  Object? lastError;
  var anySuccess = false;

  try {
    for (var i = 0; i < seeds.length; i++) {
      final seed = seeds[i];
      final fallback = fallbackVehicles[i % fallbackVehicles.length];
      try {
        final remoteVehicle = await fetchVehicleFromGraphQl(
          endpoint: endpoint,
          id: seed.id,
          driver: seed.driver,
          plate: seed.plate,
          note: seed.note,
          client: resolvedClient,
        );

        if (remoteVehicle != null) {
          resolvedVehicles.add(remoteVehicle);
          anySuccess = true;
        } else {
          resolvedVehicles.add(fallback);
        }
      } catch (error) {
        lastError = error;
        resolvedVehicles.add(fallback);
      }
    }
  } finally {
    if (client == null) {
      resolvedClient.close();
    }
  }

  if (!anySuccess && lastError != null) {
    throw lastError;
  }

  return resolvedVehicles;
}
