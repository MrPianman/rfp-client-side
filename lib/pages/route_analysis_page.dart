import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteAnalysisPage extends StatelessWidget {
  const RouteAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routeA = [
      const LatLng(37.7749, -122.4194),
      const LatLng(37.7799, -122.4294),
      const LatLng(37.7849, -122.4394),
    ];
    final routeB = [
      const LatLng(37.7749, -122.4194),
      const LatLng(37.7699, -122.4094),
      const LatLng(37.7649, -122.3994),
    ];

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: const MapOptions(initialCenter: LatLng(37.7749, -122.4194), initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.revnotwo',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(points: routeA, color: Colors.blue, strokeWidth: 5),
                  Polyline(points: routeB, color: Colors.green, strokeWidth: 5),
                ],
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Metrics'),
                SizedBox(height: 8),
                Text('Distance: 120 vs 112 km'),
                Text('Time: 3h 20m vs 2h 55m'),
                Text('Fuel cost: 48 vs 42'),
                Text('Profit margin: +6%'),
                Divider(),
                Text('Suggestion: Switch route order for +8% efficiency'),
              ],
            ),
          ),
        )
      ],
    );
  }
}
