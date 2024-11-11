import 'package:attendanceapp/screens/attendancescreen.dart';
import 'package:attendanceapp/screens/homescreen.dart';
import 'package:attendanceapp/screens/profilescreen.dart';
import 'package:attendanceapp/screens/settingscreen.dart';
import 'package:attendanceapp/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      AttendanceScreen(),
      ProfileScreen(),
      const SettingsScreen(),
    ];
  }

  final List<IconData> _navigationIcons = [
    Icons.home,
    Icons.access_time,
    Icons.person,
    Icons.settings,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navigationIcons.length, (i) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(i),
                  child: Icon(
                    _navigationIcons[i],
                    color: i == _selectedIndex ? Colors.red : Colors.black54,
                    size: i == _selectedIndex ? 32 : 26,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
