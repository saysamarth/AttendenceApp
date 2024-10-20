import 'dart:io';
import 'package:flutter/material.dart';
import 'package:attendanceapp/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String checkInTime = '--:--';
  String checkOutTime = '--:--';
  String checkInLocation = 'Location not available';
  String checkOutLocation = 'Location not available';
  bool isCheckedIn = false;
  bool isCheckOutEnabled = false;
  String? checkInPhotoPath;
  String? checkOutPhotoPath;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadCheckInStateFromFirebase();
  }

  Future<void> _loadCheckInStateFromFirebase() async {
    final User? user = auth.currentUser;
    if (user == null) return;

    QuerySnapshot checkInSnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('attendance')
        .where('date', isEqualTo: DateTime.now().toString().substring(0, 10))
        .get();

    if (checkInSnapshot.docs.isNotEmpty) {
      var data = checkInSnapshot.docs.first.data() as Map<String, dynamic>;

      if (data['checkOutTime'] == null) {
        setState(() {
          isCheckedIn = true;
          checkInTime = data['checkInTime'] ?? '--:--';
          checkInLocation = data['checkInLocation'] ?? 'Location not available';
          checkInPhotoPath = data['checkInPhotoPath'];
          isCheckOutEnabled = true;
        });
      } else {
        resetAttendance();
      }
    }
  }

  Future<void> storeCheckInDataToFirebase() async {
    final User? user = auth.currentUser;
    if (user == null) return;

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('attendance')
        .add({
      'checkInTime': checkInTime,
      'checkInLocation': checkInLocation,
      'checkInPhotoPath': checkInPhotoPath ?? '',
      'date': DateTime.now().toString().substring(0, 10),
    });
  }

  Future<void> updateCheckOutDataInFirebase(String documentId) async {
    final User? user = auth.currentUser;
    if (user == null) return;

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('attendance')
        .doc(documentId)
        .update({
      'checkOutTime': checkOutTime,
      'checkOutLocation': checkOutLocation,
      'checkOutPhotoPath': checkOutPhotoPath ?? '',
    });
  }

  Future<void> capturePhotoAndLocation(bool isCheckIn) async {
    String currentTime = TimeOfDay.now().format(context);
    String currentLocation = await getCurrentLocation(context); 
    String? photoPath = await pickimage();
    final User? user = auth.currentUser;

    if (isCheckIn) {
      setState(() {
        isCheckedIn = true;
        checkInTime = currentTime;
        checkInLocation = currentLocation;
        checkInPhotoPath = photoPath;
        isCheckOutEnabled = true;
      });
      await storeCheckInDataToFirebase();
    } else {
      setState(() {
        checkOutTime = currentTime;
        checkOutLocation = currentLocation;
        checkOutPhotoPath = photoPath;
        isCheckOutEnabled = false;
      });
      QuerySnapshot checkInSnapshot = await firestore
          .collection('users')
          .doc(user?.uid)
          .collection('attendance')
          .where('date', isEqualTo: DateTime.now().toString().substring(0, 10))
          .get();

      if (checkInSnapshot.docs.isNotEmpty) {
        await updateCheckOutDataInFirebase(checkInSnapshot.docs.first.id);
      }

      await showAttendanceDialog();
      resetAttendance();
    }
  }

  Future<void> showAttendanceDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 20),
              Text(
                'Attendance Marked!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Your check-in and check-out have been recorded.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void resetAttendance() {
    setState(() {
      checkInTime = '--:--';
      checkOutTime = '--:--';
      checkInLocation = 'Location not available';
      checkOutLocation = 'Location not available';
      isCheckedIn = false;
      isCheckOutEnabled = false;
      checkInPhotoPath = null;
      checkOutPhotoPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: FutureBuilder<DocumentSnapshot>(
          future: firestore.collection('users').doc(user?.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final userData = snapshot.data?.data() as Map<String, dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome, ${userData['name']}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 55),
                buildAttendanceCard(
                  title: 'Check-In Time',
                  time: isCheckedIn ? checkInTime : '--:--',
                  location:
                      isCheckedIn ? checkInLocation : 'Location not available',
                  photoPath: checkInPhotoPath,
                  color: Colors.blue.shade50,
                ),
                const SizedBox(height: 30),
                buildAttendanceCard(
                  title: 'Check-Out Time',
                  time: checkOutTime,
                  location: checkOutLocation,
                  photoPath: checkOutPhotoPath,
                  color: Colors.orange.shade50,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (!isCheckedIn) {
                      await capturePhotoAndLocation(true); // Check-In
                    } else if (isCheckOutEnabled) {
                      await capturePhotoAndLocation(false); // Check-Out
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(isCheckedIn
                      ? 'Check Out with Photo'
                      : 'Check In with Photo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shadowColor: isCheckedIn ? Colors.orange : Colors.blue,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildAttendanceCard(
      {required String title,
      required String time,
      required String location,
      String? photoPath,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoPath != null && File(photoPath).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(photoPath),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('Time: $time'),
                Text('Location: $location'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
