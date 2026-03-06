// lib/screens/control_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/mqtt_service.dart';
import '../widgets/conn_dot.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttService>(builder: (context, mqtt, _) {
      return Scaffold(
        body: SafeArea(
          child: Column(children: [
            // HEADER
            Container(
              color: kCard,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(children: [
                const Text('🎛️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text('ควบคุม',
                    style: GoogleFonts.sarabun(fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                ConnDot(isConnected: mqtt.isConnected, isConnecting: mqtt.isConnecting),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [

                  // MODE
                  _label('🌙 โหมดระบบ'),
                  const SizedBox(height: 10),
                  _card(child: Row(children: [
                    Text(mqtt.nightMode ? '🌙' : '☀️',
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        mqtt.nightMode ? 'โหมดกลางคืน' : 'โหมดกลางวัน',
                        style: GoogleFonts.sarabun(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        mqtt.nightMode ? 'Reed sensor ประตูทำงาน' : 'Reed sensor ประตูปิด',
                        style: GoogleFonts.sarabun(fontSize: 12, color: kMuted),
                      ),
                    ]),
                    const Spacer(),
                    _sw(mqtt.nightMode, kBlue, (v) => mqtt.setMode(v)),
                  ])),
                  const SizedBox(height: 20),

                  // LED
                  _label('💡 ไฟ LED ขาว'),
                  const SizedBox(height: 10),
                  _card(child: Column(children: [
                    Row(children: [
                      Text('ทั้งหมด',
                          style: GoogleFonts.sarabun(fontSize: 13, color: kMuted)),
                      const Spacer(),
                      _textBtn('เปิดทั้งหมด', kGreen, () => mqtt.setLed('all', true)),
                      const SizedBox(width: 8),
                      _textBtn('ปิดทั้งหมด',  kRed,   () => mqtt.setLed('all', false)),
                    ]),
                    const Divider(color: kBorder, height: 20),
                    _ledRow('💡 LED ขาว โซน 1', mqtt.ledWhite1,
                        (v) => mqtt.setLed('white1', v)),
                    const SizedBox(height: 10),
                    _ledRow('💡 LED ขาว โซน 2', mqtt.ledWhite2,
                        (v) => mqtt.setLed('white2', v)),
                    const SizedBox(height: 10),
                    _ledRow('💡 LED ขาว โซน 3', mqtt.ledWhite3,
                        (v) => mqtt.setLed('white3', v)),
                  ])),
                  const SizedBox(height: 20),

                  // SENSOR TOGGLES
                  _label('⚙️ เปิด/ปิดระบบเซนเซอร์'),
                  const SizedBox(height: 10),
                  _sensorRow('🔥', 'ระบบตรวจควัน (MQ2)',          'Threshold: 400',
                      mqtt.enableSmoke,     (v) => mqtt.setSensor('smoke', v)),
                  const SizedBox(height: 10),
                  _sensorRow('🌍', 'ระบบตรวจสั่นสะเทือน (MPU6050)', 'Threshold: 5000',
                      mqtt.enableVibration, (v) => mqtt.setSensor('vibration', v)),
                  const SizedBox(height: 10),
                  _sensorRow('🚪', 'ระบบตรวจประตู (Reed)',           'ทำงานเฉพาะโหมดกลางคืน',
                      mqtt.enableDoor,      (v) => mqtt.setSensor('door', v)),
                ],
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.sarabun(fontSize: 13, fontWeight: FontWeight.w700, color: kMuted));

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kCard, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kBorder),
    ),
    child: child,
  );

  Widget _sw(bool val, Color color, ValueChanged<bool> cb) => Switch(
    value: val, onChanged: cb,
    activeColor: color, activeTrackColor: color.withOpacity(0.3),
    inactiveThumbColor: kMuted, inactiveTrackColor: kBorder,
  );

  Widget _ledRow(String label, bool val, ValueChanged<bool> cb) => Row(children: [
    AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 12, height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: val ? const Color(0xFFFFF9C4) : kMuted.withOpacity(0.3),
        boxShadow: val ? [BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 6)] : [],
      ),
    ),
    const SizedBox(width: 10),
    Text(label, style: GoogleFonts.sarabun(fontSize: 14)),
    const Spacer(),
    _sw(val, const Color(0xFFF0E68C), cb),
  ]);

  Widget _textBtn(String label, Color color, VoidCallback onTap) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      backgroundColor: color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Text(label, style: GoogleFonts.sarabun(fontSize: 12, color: color)),
  );

  Widget _sensorRow(String icon, String label, String sub, bool val, ValueChanged<bool> cb) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.sarabun(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(sub,   style: GoogleFonts.sarabun(fontSize: 11, color: kMuted)),
          ])),
          _sw(val, kBlue, cb),
        ]),
      );
}
