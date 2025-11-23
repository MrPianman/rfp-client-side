class Vehicle {
  final String id;
  final String driver;
  final String status; // moving, idle, offline
  final double lat;
  final String plate;
  final String note;
  final double lng;
  final double speedKph;
  final double fuelEfficiency;

  const Vehicle({
    required this.plate,
    required this.id,
    required this.note,
    required this.driver,
    required this.status,
    required this.lat,
    required this.lng,
    required this.speedKph,
    required this.fuelEfficiency,
  });
}
