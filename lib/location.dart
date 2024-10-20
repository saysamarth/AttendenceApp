import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<String> getCurrentLocation(BuildContext context) async {
  LocationPermission permission;
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return "Location services are disabled.";
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return "Location permission denied by user.";
    }
  }

  if (permission == LocationPermission.deniedForever) {
    _showPermissionDialog(context);
    return "Location permissions are permanently denied.";
  }
  Position currentPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  return "Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}";
}

void _showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text(
            "Location permission is permanently denied. Please enable it in the app settings."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text("Open Settings"),
          ),
        ],
      );
    },
  );
}

Future pickimage() async {
  final returnedimage =
      await ImagePicker().pickImage(source: ImageSource.camera);
  if (returnedimage == null) return;
  return returnedimage.path;
}
