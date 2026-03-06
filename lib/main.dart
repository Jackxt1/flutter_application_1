// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';
import 'screens/home_screen.dart';

const kBg     = Color(0xFF0D1117);
const kCard   = Color(0xFF161B22);
const kBorder = Color(0xFF30363D);
const kBlue   = Color(0xFF58A6FF);
const kGreen  = Color(0xFF3FB950);
const kRed    = Color(0xFFF85149);
const kOrange = Color(0xFFD29922);
const kMuted  = Color(0xFF8B949E);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => MqttService()..connect(),
      child: const SmartHomeApp(),
    ),
  );
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kBlue, secondary: kGreen),
        textTheme: GoogleFonts.sarabunTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}
