class FleetAlert {
  final String id;
  final String type; // speeding, idle, maintenance
  final String message;
  final DateTime time;
  final bool read;

  const FleetAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.time,
    this.read = false,
  });

  FleetAlert copyWith({bool? read}) => FleetAlert(
        id: id,
        type: type,
        message: message,
        time: time,
        read: read ?? this.read,
      );
}
