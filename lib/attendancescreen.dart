import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance',
            style: GoogleFonts.stixTwoText(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w500)),
        backgroundColor: const Color.fromARGB(255, 163, 201, 219),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .collection('attendance')
              .orderBy('date', descending: true)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No attendance record found."));
            }

            final attendanceData = snapshot.data!.docs;

            return ListView.builder(
              itemCount: attendanceData.length,
              itemBuilder: (ctx, index) {
                final record =
                    attendanceData[index].data() as Map<String, dynamic>;
                final checkInTime = record['checkInTime'] is Timestamp
                    ? (record['checkInTime'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                        .substring(11, 16)
                    : record['checkInTime'] ?? '--:--';

                final checkOutTime = record['checkOutTime'] is Timestamp
                    ? (record['checkOutTime'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                        .substring(11, 16)
                    : record['checkOutTime'] ?? '--:--';

                final checkInLocation = record['checkInLocation'] ?? 'N/A';
                final checkOutLocation = record['checkOutLocation'] ?? 'N/A';
                final date = record['date'] is Timestamp
                    ? (record['date'] as Timestamp).toDate()
                    : DateTime.now();
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    title: Text(
                      'Date: ${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Check-In Time: $checkInTime'),
                        Text('Check-In Location: $checkInLocation'),
                        const SizedBox(height: 5),
                        Text('Check-Out Time: $checkOutTime'),
                        Text('Check-Out Location: $checkOutLocation'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
