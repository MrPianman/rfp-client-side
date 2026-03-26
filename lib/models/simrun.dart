class SimCar {
  final String id;
  final double cost;

  const SimCar({
    required this.id,
    required this.cost,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cost': cost,
    };
  }
}

class SimRun {
  final String runId;
  final double totalDistance;
  final List<SimCar> cars;

  const SimRun({
    required this.runId,
    required this.totalDistance,
    required this.cars,
  });

  Map<String, dynamic> toJson() {
    return {
      'run_id': runId,
      'total_distance': totalDistance,
      'cars': cars.map((car) => car.toJson()).toList(),
    };
  }
}