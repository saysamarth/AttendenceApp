import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildActivitySection(
    {required String checkinTime, required String checkoutTime}) {
  final DateFormat timeFormat = DateFormat("hh:mm a");
  DateTime? checkInTime;
  DateTime? checkOutTime;
  try {
    checkInTime = timeFormat.parse(checkinTime);
    checkOutTime = timeFormat.parse(checkoutTime);
  } catch (e) {
    print("Error parsing time: $e");
  }
  if (checkInTime != null && checkOutTime != null) {
    String attendanceStatus = "Marked ✅ ";
    final String checkInStatus = checkInTime.hour > 9 ? "Late" : "On Time";
    final String checkOutStatus = checkOutTime.hour >= 18
        ? "Overtime"
        : checkOutTime.hour < 17
            ? "Early"
            : "On Time";
    final Duration workingHours = checkOutTime.difference(checkInTime);

    final List<Widget> activityCards = [
      buildActivityCard(
          const Icon(
            Icons.flag_circle_outlined,
          ),
          'Attendance Status',
          attendanceStatus),
      buildActivityCard(const Icon(Icons.pin_drop), 'Check-In', checkInStatus),
      buildActivityCard(
          const Icon(Icons.exit_to_app), 'Check-Out', checkOutStatus),
      buildActivityCard(const Icon(Icons.access_time), 'Total Working Hours',
          '${workingHours.inHours} hours ${workingHours.inMinutes % 60} minutes'),
    ];

    return Column(
      children: [
        Column(children: activityCards),
      ],
    );
  }
  return const SizedBox.shrink();
}

Widget buildActivityCard(Icon icon, String title, String value) {
  return Card(
    elevation: 2,
    color: const Color.fromARGB(255, 255, 255, 255),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
    child: Padding(
      padding: const EdgeInsets.all(13.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: const Color.fromARGB(255, 235, 246, 255),
            ),
            height: 35,
            width: 35,
            child: icon,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    ),
  );
}
