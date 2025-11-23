import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/mock_data.dart';

class LiveMapPage extends StatefulWidget {
  const LiveMapPage({super.key});

  @override
  State<LiveMapPage> createState() => _LiveMapPageState();
}

class _LiveMapPageState extends State<LiveMapPage> {
  final MapController _mapController = MapController();
  double _rotation = 0.0;

  @override
  void initState() {
    super.initState();
    _mapController.mapEventStream.listen((event) {
      if (event is MapEventRotate) {
        setState(() {
          _rotation = event.camera.rotation;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = mockVehicles();
    final center = LatLng(vehicles.first.lat, vehicles.first.lng);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 12,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.revnotwo',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final v in vehicles)
                        Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(v.lat, v.lng),
                          child: Icon(
                            Icons.directions_car,
                            color: v.status == 'moving'
                                ? Colors.green
                                : v.status == 'idle'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: _rotation * (3.14159 / 180),
                    child: Icon(
                      Icons.explore,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final v = vehicles[i];
              return Chip(
                label: Text('${v.id} • ${v.driver} • ${v.speedKph.toStringAsFixed(0)} km/h'),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: vehicles.length,
          ),
        )
      ],
    );
  }
}
