// lib/screens/sensor_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/mqtt_service.dart';
import '../widgets/conn_dot.dart';
import '../widgets/sensor_tile.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttService>(builder: (context, mqtt, _) {
      final isAlert = mqtt.status != 'NORMAL';
      return Scaffold(
        body: SafeArea(
          child: Column(children: [
            // HEADER
            Container(
              color: kCard,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(children: [
                const Text('📊', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text('ค่าเซนเซอร์',
                    style: GoogleFonts.sarabun(fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                ConnDot(isConnected: mqtt.isConnected, isConnecting: mqtt.isConnecting),
              ]),
            ),
            Expanded(
              child: RefreshIndicator(
                color: kBlue,
                backgroundColor: kCard,
                onRefresh: mqtt.connect,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [

                    // STATUS BANNER
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isAlert ? kRed.withOpacity(0.12) : kGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAlert ? kRed.withOpacity(0.5) : kGreen.withOpacity(0.4),
                        ),
                      ),
                      child: Row(children: [
                        Text(isAlert ? '🚨' : '✅', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            isAlert ? 'พบสัญญาณแจ้งเตือน' : 'ระบบปกติ',
                            style: GoogleFonts.sarabun(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: isAlert ? kRed : kGreen,
                            ),
                          ),
                          Text(mqtt.status,
                              style: GoogleFonts.sarabun(fontSize: 12, color: kMuted)),
                        ]),
                        const Spacer(),
                        Text(
                          mqtt.nightMode ? '🌙 กลางคืน' : '☀️ กลางวัน',
                          style: GoogleFonts.sarabun(fontSize: 12, color: kMuted),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // SENSOR TILES
                    Text('📊 ค่าเซนเซอร์ Real-time',
                        style: GoogleFonts.sarabun(
                            fontSize: 13, fontWeight: FontWeight.w700, color: kMuted)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: SensorTile(
                        icon: '🔥', label: 'ควัน',
                        value: mqtt.smoke.toString(), unit: 'ppm',
                        color: mqtt.smoke > 400 ? kRed : kGreen,
                        barValue: (mqtt.smoke / 1023).clamp(0, 1).toDouble(),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: SensorTile(
                        icon: '🌍', label: 'สั่นสะเทือน',
                        value: mqtt.vibration.toString(), unit: '',
                        color: mqtt.vibration > 5000 ? kOrange : kGreen,
                        barValue: (mqtt.vibration / 20000).clamp(0, 1).toDouble(),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: SensorTile(
                        icon: '🚪', label: 'ประตู',
                        value: mqtt.doorOpen ? 'เปิด' : 'ปิด', unit: '',
                        color: mqtt.doorOpen ? kRed : kGreen,
                        barValue: mqtt.doorOpen ? 1.0 : 0.0,
                      )),
                    ]),
                    const SizedBox(height: 20),

                    // SENSOR STATUS
                    Text('🔌 สถานะระบบเซนเซอร์',
                        style: GoogleFonts.sarabun(
                            fontSize: 13, fontWeight: FontWeight.w700, color: kMuted)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: kCard, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(children: [
                        _statusRow('🔥', 'ควัน (MQ2)',            mqtt.enableSmoke,     0),
                        _statusRow('🌍', 'สั่นสะเทือน (MPU6050)', mqtt.enableVibration, 1),
                        _statusRow('🚪', 'ประตู (Reed)',            mqtt.enableDoor,      2),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _statusRow(String icon, String label, bool enabled, int index) {
    return Column(children: [
      if (index > 0) const Divider(color: kBorder, height: 1),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.sarabun(fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: enabled ? kGreen.withOpacity(0.15) : kMuted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              enabled ? 'เปิด' : 'ปิด',
              style: GoogleFonts.sarabun(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: enabled ? kGreen : kMuted,
              ),
            ),
          ),
        ]),
      ),
    ]);
  }
}
