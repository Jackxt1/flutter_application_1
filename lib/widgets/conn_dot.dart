// lib/widgets/conn_dot.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class ConnDot extends StatelessWidget {
  final bool isConnected, isConnecting;
  const ConnDot({super.key, required this.isConnected, required this.isConnecting});

  @override
  Widget build(BuildContext context) {
    final color = isConnecting ? kOrange : (isConnected ? kGreen : kRed);
    final label = isConnecting ? 'กำลังเชื่อมต่อ...' : (isConnected ? 'Online' : 'Offline');
    return Row(children: [
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.sarabun(fontSize: 12, color: color)),
    ]);
  }
}
