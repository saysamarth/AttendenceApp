import 'package:attendanceapp/widgets/activitysection.dart';
import 'package:attendanceapp/widgets/attendence_card.dart';
import 'package:attendanceapp/widgets/horizontaldate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> _fetchAttendanceData(DateTime date) async {
    final user = auth.currentUser;
    if (user == null) return null;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final snapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('attendance')
        .where('date', isEqualTo: dateStr)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    } else {
      return null;
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Attendance',
          style: GoogleFonts.stixTwoText(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 163, 201, 219),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Horizontaldate(
              fromDate: DateTime.now(),
              selectedDate: selectedDate,
              toDate: DateTime.now().add(const Duration(days: 10)),
              onDateSelected: _onDateSelected,
            ),
          ),
          const SizedBox(height: 30),
          FutureBuilder<Map<String, dynamic>?>(
            future: _fetchAttendanceData(selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: Text(
                    'No data available.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  )),
                );
              }

              final attendanceData = snapshot.data!;
              return Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  children: [
                    const Text(
                      "Today's Attendence",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    AttendanceCard(
                      title: 'Check-In',
                      time: attendanceData['checkInTime'] ?? '--:--',
                      location: attendanceData['checkInLocation'] ??
                          'a:Location not available, a:Location not available,',
                      photoURL: attendanceData['checkInPhotoPath'],
                      color: Colors.blue.shade50,
                    ),
                    const SizedBox(height: 20),
                    AttendanceCard(
                      title: 'Check-Out',
                      time: attendanceData['checkOutTime'] ?? '--:--',
                      location: attendanceData['checkOutLocation'] ??
                          'a:Location not available, a:Location not available, ',
                      photoURL: attendanceData['checkOutPhotoPath'],
                      color: Colors.orange.shade50,
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    const Text(
                      "Your Activity",
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    buildActivitySection(
                        checkinTime: attendanceData['checkInTime'],
                        checkoutTime: attendanceData['checkOutTime']),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
