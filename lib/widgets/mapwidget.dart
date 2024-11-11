import 'package:attendanceapp/screens/fullmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapView extends StatelessWidget {
  final LatLng location;
  final double zoomLevel;
  final int interactiveFlags1;
  final int interactiveFlags2;

  const MapView(
      {super.key,
      required this.location,
      required this.zoomLevel,
      required this.interactiveFlags1,
      required this.interactiveFlags2});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        interactionOptions:
            InteractionOptions(flags: interactiveFlags1 | interactiveFlags2),
        initialCenter: location,
        initialZoom: zoomLevel,
        onTap: (tapPosition, point) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenMapScreen(location: location),
            ),
          );
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80,
              height: 80,
              point: location,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
