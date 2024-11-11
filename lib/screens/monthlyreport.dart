import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  int presentDays = 0;
  int absentDays = 0;
  int touchedIndex = -1;

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

    return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
  }

  Future<void> _calculateMonthlyAttendance() async {
    DateTime now = DateTime.now();
    int daysInMonth = DateTime.now().day;
    int tempPresentDays = 0;
    int tempAbsentDays = 0;

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDate = DateTime(now.year, now.month, i);
      var attendanceData = await _fetchAttendanceData(currentDate);
      attendanceData != null ? tempPresentDays++ : tempAbsentDays++;
    }

    setState(() {
      presentDays = tempPresentDays;
      absentDays = tempAbsentDays;
    });
  }

  @override
  void initState() {
    super.initState();
    _calculateMonthlyAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: const Color.fromARGB(255, 198, 206, 209),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Monthly Attendance Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: showingSections(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Indicator(
                          color: Colors.green, text: 'Present', isSquare: true),
                      SizedBox(height: 4),
                      Indicator(
                          color: Colors.red, text: 'Absent', isSquare: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 18 : 14;
      final double radius = isTouched ? 60 : 50;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: presentDays.toDouble(),
            title:
                '${((presentDays / (presentDays + absentDays)) * 100).toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: absentDays.toDouble(),
            title:
                '${((absentDays / (presentDays + absentDays)) * 100).toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          );
        default:
          throw Error();
      }
    });
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
