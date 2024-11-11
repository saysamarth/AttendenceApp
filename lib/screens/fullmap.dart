import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class FullScreenMapScreen extends StatelessWidget {
  final LatLng location;
  const FullScreenMapScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          backgroundColor: const Color.fromARGB(255, 198, 206, 209),
          centerTitle: true,
        ),
        body: FlutterMap(
          options: MapOptions(
            interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchMove |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.flingAnimation |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom),
            initialCenter: location,
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.myAttendanceApp',
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
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
