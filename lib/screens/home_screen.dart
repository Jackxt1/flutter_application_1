// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'sensor_screen.dart';
import 'control_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    SensorScreen(),
    ControlScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kCard,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: kBlue,
          unselectedItemColor: kMuted,
          selectedLabelStyle: GoogleFonts.sarabun(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.sarabun(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.sensors),   label: 'เซนเซอร์'),
            BottomNavigationBarItem(icon: Icon(Icons.toggle_on), label: 'ควบคุม'),
          ],
        ),
      ),
    );
  }
}
