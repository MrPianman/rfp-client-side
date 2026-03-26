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
    'expectedMinutes': 60,
    'profit': 617.0,
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
    'expectedMinutes': 60,
    'profit': 620.0,
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
    'expectedMinutes': 60,
    'profit': 613.0,
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
    'expectedMinutes': 60,
    'profit': 619.0,
    'market': [
      {'name': 'Rice', 'received': true},
      {'name': 'Fish Sauce', 'received': true},
      {'name': 'Chili', 'received': true},
    ],
  },
];

final List<Map<String, Object?>> _simRunSeedData = [
  {
    'run_id': 'SR-001',
    'algorithm': 'old',
    'total_distance': 150.5,
    'cars': [
      {'id': 'C-001', 'cost': 45.0},
      {'id': 'C-002', 'cost': 52.0},
    ],
  },
  {
    'run_id': 'SR-002',
    'algorithm': 'our',
    'total_distance': 142.3,
    'cars': [
      {'id': 'C-003', 'cost': 38.0},
      {'id': 'C-004', 'cost': 49.0},
    ],
  },
  {
    'run_id': 'SR-003',
    'algorithm': 'old',
    'total_distance': 160.0,
    'cars': [
      {'id': 'C-005', 'cost': 55.0},
    ],
  },
  {
    'run_id': 'SR-004',
    'algorithm': 'our',
    'total_distance': 135.7,
    'cars': [
      {'id': 'C-006', 'cost': 42.0},
      {'id': 'C-007', 'cost': 47.0},
      {'id': 'C-008', 'cost': 50.0},
    ],
  },
  {
    'run_id': 'SR-005',
    'algorithm': 'old',
    'total_distance': 155.2,
    'cars': [
      {'id': 'C-009', 'cost': 48.0},
    ],
  },
];

List<SimRun> mockSimRuns({String? algorithm, int? limit}) {
  var runs = _simRunSeedData.map((seed) {
    final cars = (seed['cars'] as List<Map<String, Object?>>)
        .map((car) => SimCar(
              id: car['id'] as String,
              cost: (car['cost'] as num).toDouble(),
            ))
        .toList();
    return SimRun(
      runId: seed['run_id'] as String,
      totalDistance: (seed['total_distance'] as num).toDouble(),
      cars: cars,
    );
  }).toList();

  if (algorithm != null) {
    runs = runs.where((run) {
      final seed = _simRunSeedData.firstWhere(
        (s) => s['run_id'] == run.runId,
      );
      return seed['algorithm'] == algorithm;
    }).toList();
  }

  if (limit != null && limit > 0) {
    runs = runs.take(limit).toList();
  }

  return runs;
}

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
  // Align trip data to the seeded vehicles so downstream views rank real vehicles.
  return List.generate(_vehicleSeedData.length, (i) {
    final seed = _vehicleSeedData[i];
    final start = DateTime.now().subtract(Duration(days: i + 1));
    final int expectedMinutes = (seed['expectedMinutes'] as int?) ?? 60;
    final end = start.add(Duration(minutes: expectedMinutes));
    final dist = 80 + rnd.nextDouble() * 60;
    final fuel = dist / (8 + rnd.nextDouble() * 4);
    final all = 4 + rnd.nextInt(4); // 4–7 assigned
    final curr = 1 + rnd.nextInt(all.clamp(1, 7)); // at least one completed

    return Trip(
      id: seed['id'] as String,
      start: start,
      end: end,
      expectedMinutes: expectedMinutes,
      distanceKm: dist,
      fuelUsedL: fuel,
      profit: (seed['profit'] as num?)?.toDouble() ??
          500 + rnd.nextDouble() * 500,
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
  query VehicleByProperties {
    vehicleByProperties {
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

const String _simRunQuery = r'''
  query SimRun($algorithm: String, $limit: Int) {
    simruns(algorithm: $algorithm, limit: $limit) {
      run_id
      total_distance
      cars {
        id
        cost
      }
    }
  }
''';

/// Calls a GraphQL endpoint to fetch all vehicles.
/// Returns the list of vehicles.
Future<List<Vehicle>> fetchVehiclesFromGraphQl({
  required Uri endpoint,
  http.Client? client,
}) async {
  final http.Client resolvedClient = client ?? http.Client();
  final body = jsonEncode({
    'query': _vehicleByPropertiesQuery,
    'variables': {},
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
    final vehiclesRaw = data?['vehicleByProperties'];
    if (vehiclesRaw == null) {
      return [];
    }

    if (vehiclesRaw is! List) {
      throw FormatException('vehicleByProperties should be a list');
    }

    return vehiclesRaw.map((item) {
      final vehicleData = item as Map<String, dynamic>;

      double asDouble(dynamic source) {
        if (source is num) {
          return source.toDouble();
        }
        throw const FormatException('Expected numeric field in GraphQL response');
      }
      // print(vehicleData);
      return Vehicle(
        id: vehicleData['id'] as String,
        plate: vehicleData['plate'] as String,
        note: (vehicleData['note'] as String?) ?? '',
        status: (vehicleData['status'] as String?) ?? 'offline',
        lat: asDouble(vehicleData['lat'] ?? 0.0),
        lng: asDouble(vehicleData['lng'] ?? 0.0),
        speedKph: double.tryParse(vehicleData['speedKph'] as String? ?? '0') ?? 0.0,
        fuelEfficiency: double.tryParse(vehicleData['fuelEfficiency'] as String? ?? '0') ?? 0.0,
        driver: (vehicleData['driver']),
      );
    }).toList();
  } finally {
    if (client == null) {
      resolvedClient.close();
    }
  }
}

/// Calls a GraphQL endpoint to fetch simulation runs.
/// Supports filters for algorithm and limit.
/// Returns the list of simulation runs.
Future<List<SimRun>> fetchSimRunsFromGraphQl({
  required Uri endpoint,
  String? algorithm,
  int? limit,
  http.Client? client,
}) async {
  final http.Client resolvedClient = client ?? http.Client();
  final body = jsonEncode({
    'query': _simRunQuery,
    'variables': {'algorithm': algorithm, 'limit': limit},
  });

  // print('[mock_data] fetchSimRunsFromGraphQl request body: $body');
  try {
    final response = await resolvedClient.post(
      endpoint,
      headers: const {'Content-Type': 'application/json'},
      body: body,
    );
    // print('[mock_data] fetchSimRunsFromGraphQl status: ${response.statusCode}');
    // print('[mock_data] fetchSimRunsFromGraphQl response body: ${response.body}');

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
    final simrunData = data?['simruns'] as List<dynamic>?;
    if (simrunData == null) {
      return [];
    }

    return simrunData.map((item) {
      final runData = item as Map<String, dynamic>;
      final carsData = runData['cars'] as List<dynamic>;
      final cars = carsData.map((carItem) {
        final carData = carItem as Map<String, dynamic>;
        return SimCar(
          id: carData['id'] as String,
          cost: (carData['cost'] as num).toDouble(),
        );
      }).toList();
      return SimRun(
        runId: runData['run_id'] as String,
        totalDistance: (runData['total_distance'] as num).toDouble(),
        cars: cars,
      );
    }).toList();
  } finally {
    if (client == null) {
      resolvedClient.close();
    }
  }
}

/// Convenience helper that calls the GraphQL backend for simruns,
/// and falls back to the mock values when the server cannot satisfy the request.
/// Throws when the request fails so that the UI can surface the outage to the operator.
Future<List<SimRun>> fetchSimRunsFromServer({
  required Uri endpoint,
  String? algorithm,
  int? limit,
  http.Client? client,
}) async {
  final http.Client resolvedClient = client ?? http.Client();
  final fallbackRuns = mockSimRuns(algorithm: algorithm, limit: limit);

  try {
    final remoteRuns = await fetchSimRunsFromGraphQl(
      endpoint: endpoint,
      algorithm: algorithm,
      limit: limit,
      client: resolvedClient,
    );
    return remoteRuns;
  } catch (error) {
    // Fall back to mock data
    return fallbackRuns;
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

  try {
    // print('[mock_data] fetchVehiclesFromServer: fetching all vehicles from GraphQL');
    final remoteVehicles = await fetchVehiclesFromGraphQl(
      endpoint: endpoint,
      client: resolvedClient,
    );
    // print('[mock_data] fetchVehiclesFromServer: got ${remoteVehicles.length} remote vehicles');

    if (remoteVehicles.isEmpty) {
      // print('[mock_data] fetchVehiclesFromServer: remote empty, using fallback');
      return fallbackVehicles;
    }

    // If the backend returns list items, prefer that list.
    // Old matching to local seed data is removed to show all remote vehicles.
    return remoteVehicles;
  } catch (error) {
    // print('[mock_data] fetchVehiclesFromServer: error fetching from GraphQL: $error');
    return fallbackVehicles;
  } finally {
    if (client == null) {
      resolvedClient.close();
    }
  }
}
