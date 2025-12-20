import '../data/mock_data.dart';
import '../models/vehicle.dart';

class VehicleRepositoryResult {
  VehicleRepositoryResult({required this.vehicles, this.error});

  final List<Vehicle> vehicles;
  final String? error;

  bool get hasError => error != null;
}

class VehicleRepository {
  const VehicleRepository();

  Future<VehicleRepositoryResult> fetchVehicles(Uri endpoint) async {
    try {
      final vehicles = await fetchVehiclesFromServer(endpoint: endpoint);
      return VehicleRepositoryResult(vehicles: vehicles);
    } catch (e) {
      return VehicleRepositoryResult(vehicles: mockVehicles(), error: e.toString());
    }
  }
}
