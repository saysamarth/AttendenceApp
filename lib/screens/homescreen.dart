import 'dart:io';
import 'package:flutter/material.dart';
import 'package:attendanceapp/widgets/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String checkInTime = '--:--';
  String checkOutTime = '--:--';
  String checkInLocation = 'Location not available';
  String checkOutLocation = 'Location not available';
  bool isCheckOutEnabled = false;
  bool isCheckOutDone = false;
  bool isAttendanceMarked = false;
  var checkInPhotoPath = ' ';
  var checkOutPhotoPath = ' ';
  String username = ''; // To hold the username
  bool isLoading = true; // To track loading state

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadCheckInStateFromLocal();
  }

  Future<void> _loadUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Try to load username from SharedPreferences
    username = prefs.getString('username') ?? '';
    // If username is not found, fetch it from Firestore
    if (username.isEmpty) {
      final User? user = auth.currentUser;
      if (user != null) {
        try {
          final userDoc = await firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            username = userDoc.data()!['name'] ?? 'User';  // Handle null username
            // Store username in SharedPreferences
            await prefs.setString('username', username);
          }
        } catch (e) {
          print("Error fetching user data: $e");
          username = 'User'; // Fallback name
        }
      }
    }
    setState(() {
      isLoading = false; // Set loading state to false after loading data
    });
  }

  Future _loadCheckInStateFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final todayDate = DateTime.now().toString().substring(0, 10);
    final storedDate = prefs.getString('checkInDate');

    if (storedDate == todayDate) {
      setState(() {
        checkInTime = prefs.getString('checkInTime') ?? '--:--';
        checkInLocation =
            prefs.getString('checkInLocation') ?? 'Location not available';
        checkInPhotoPath = prefs.getString('checkInPhotoPath') ?? '';

        if (prefs.containsKey('checkOutTime')) {
          checkOutTime = prefs.getString('checkOutTime') ?? '--:--';
          checkOutLocation =
              prefs.getString('checkOutLocation') ?? 'Location not available';
          checkOutPhotoPath = prefs.getString('checkOutPhotoPath') ?? '';
          isCheckOutDone = true;
          isAttendanceMarked = true;
        } else {
          isCheckOutEnabled = true;
        }
      });
    }
  }
  Future capturePhotoAndLocation(bool isCheckIn) async {
    String currentTime = TimeOfDay.now().format(context);
    String currentLocation = await getCurrentLocation(context);
    String photoPath = await pickimage();
    String date = DateTime.now().toString().substring(0, 10);
    final User? user = auth.currentUser;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isCheckIn) {
      setState(() {
        checkInTime = currentTime;
        checkInLocation = currentLocation;
        checkInPhotoPath = photoPath;
        isCheckOutEnabled = true;
      });

      // Save check-in data locally
      prefs.setString(
          'checkInDate', DateTime.now().toString().substring(0, 10));
      prefs.setString('checkInTime', checkInTime);
      prefs.setString('checkInLocation', checkInLocation);
      prefs.setString('checkInPhotoPath', checkInPhotoPath);
    } else {
      setState(() {
        checkOutTime = currentTime;
        checkOutLocation = currentLocation;
        checkOutPhotoPath = photoPath;
        isCheckOutDone = true;
        isAttendanceMarked = true; // Set attendance as marked
      });

      // Save check-out data locally
      prefs.setString('checkOutTime', checkOutTime);
      prefs.setString('checkOutLocation', checkOutLocation);
      prefs.setString('checkOutPhotoPath', checkOutPhotoPath);

      // Save check-in and check-out data to Firestore
      final checkInstorageref = FirebaseStorage.instance
          .ref()
          .child("attendence_image")
          .child('${user!.uid}_checkIn_$date.jpg');

      final checkOutstorageref = FirebaseStorage.instance
          .ref()
          .child("attendence_image")
          .child('${user.uid}_checkOut_$date.jpg');

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        await checkInstorageref.putFile(File(checkInPhotoPath));
        final checkInimageurl = await checkInstorageref.getDownloadURL();
        await checkOutstorageref.putFile(File(checkOutPhotoPath));
        final checkOutimageurl = await checkOutstorageref.getDownloadURL();
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('attendance')
            .add({
          'checkInTime': checkInTime,
          'checkInLocation': checkInLocation,
          'checkInPhotoPath': checkInimageurl,
          'checkOutTime': checkOutTime,
          'checkOutLocation': checkOutLocation,
          'checkOutPhotoPath': checkOutimageurl,
          'date': DateTime.now().toString().substring(0, 10),
        });
        Navigator.pop(context);
        await showAttendanceDialog();
      } on FirebaseException catch (e) {
        print('Error uploading image: $e');
        Navigator.pop(context);
      }
    }
  }

  Future<void> showAttendanceDialog() async {
    await showDialog(
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
          actions: [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child:Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                   isLoading ? 'Welcome back!' : 'Welcome, $username',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 55),
                buildAttendanceCard(
                  title: 'Check-In Time',
                  time: checkInTime,
                  location: checkInLocation,
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
                  onPressed: isAttendanceMarked
                      ? null
                      : () async {
                          if (isCheckOutDone) {
                            return;
                          }
                          if (!isCheckOutEnabled) {
                            await capturePhotoAndLocation(true);
                          } else {
                            await capturePhotoAndLocation(false);
                          }
                        },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    isAttendanceMarked
                        ? 'Attendance Marked for Today'
                        : (isCheckOutEnabled
                            ? 'Check Out with Photo'
                            : 'Check In with Photo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shadowColor:
                        isCheckOutEnabled ? Colors.orange : Colors.blue,
                  ),
                ),
              ],
            ),
          
        
      ),
    );
  }

  Widget buildAttendanceCard({
    required String title,
    required String time,
    required String location,
    String? photoPath,
    required Color color,
  }) {
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
            )
          else
            const Icon(Icons.photo, size: 60, color: Colors.grey),
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
