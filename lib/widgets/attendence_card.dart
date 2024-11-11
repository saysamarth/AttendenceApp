import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:attendanceapp/widgets/mapwidget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String title;
  final String time;
  final String location;
  final String? photoURL;
  final Color color;

  const AttendanceCard({
    super.key,
    required this.title,
    required this.time,
    required this.location,
    required this.photoURL,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    // Parsing the location string into latitude and longitude
    final List<String> locationParts = location.split(',');
    final double lat =
        double.tryParse(locationParts[0].split(':')[1].trim()) ?? 28.570339;
    final double lon =
        double.tryParse(locationParts[1].split(':')[1].trim()) ?? 77.2108999;
    final LatLng locationLatLng = LatLng(lat, lon);

    BoxDecoration tileDecoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Row(
      children: [
        // Check-In Card
        Container(
          height: 135,
          width: deviceWidth / 2 - 21,
          decoration: tileDecoration,
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.exit_to_app,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  if (photoURL != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: photoURL!,
                        width: 53,
                        height: 56,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          padding: const EdgeInsets.all(10),
                          child: const CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, size: 60),
                      ),
                    ),
                  const SizedBox(width: 11),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Time",
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Location Card with tappable map
        Container(
          decoration: tileDecoration,
          padding: const EdgeInsets.all(13),
          width: deviceWidth / 2 - 21,
          height: 135,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 2),
                  Text(
                    "$title Location",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SizedBox(
                  height: 75,
                  width: deviceWidth / 2 - 21,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MapView(
                      location: locationLatLng,
                      zoomLevel: 14,
                      interactiveFlags1: InteractiveFlag.drag,
                      interactiveFlags2: InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
