import 'package:attendanceapp/authscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 144, 174, 226)),
                  child: const Icon(
                    Icons.person_2_outlined,
                    color: Color.fromARGB(255, 33, 78, 156),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size.fromWidth(10))),
                  child: const Icon(
                    Icons.forward,
                    size: 20,
                    color: Colors.black54,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 245, 169, 125)),
                  child: const Icon(
                    Icons.language,
                    color: Color.fromARGB(255, 191, 75, 21),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                const Text(
                  "Languages",
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size.fromWidth(10))),
                  child: const Icon(
                    Icons.forward,
                    size: 20,
                    color: Colors.black54,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 224, 142, 142)),
                  child: const Icon(
                    Icons.help,
                    color: Color.fromARGB(255, 208, 50, 50),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                const Text(
                  "Help",
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size.fromWidth(10))),
                  child: const Icon(
                    Icons.forward,
                    size: 20,
                    color: Colors.black54,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 114, 194, 133)),
                  child: const Icon(
                    Icons.logout,
                    color: Color.fromARGB(255, 36, 97, 74),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => AuthenticationPage(),
                    ));
                  },
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size.fromWidth(10))),
                  icon: const Icon(
                    Icons.exit_to_app,
                    size: 25,
                    color: Color.fromARGB(255, 42, 104, 66),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
