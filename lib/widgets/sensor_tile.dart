// lib/widgets/sensor_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class SensorTile extends StatelessWidget {
  final String icon, label, value, unit;
  final Color  color;
  final double barValue;

  const SensorTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.barValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.jetBrainsMono(
            fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        if (unit.isNotEmpty)
          Text(unit, style: GoogleFonts.sarabun(fontSize: 10, color: kMuted)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: barValue, backgroundColor: kBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.sarabun(fontSize: 11, color: kMuted)),
      ]),
    );
  }
}
