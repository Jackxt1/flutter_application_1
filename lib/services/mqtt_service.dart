// lib/services/mqtt_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ============================================================
// ⚙️  NETPIE CONFIG
// ============================================================
const String kDeviceID  = 'cd843c79-b2ff-48f6-bc6c-8bc691fa7ff6';
const String kToken     = 'xqweDbQFYALULNZXWypjTPdqm5bGPqEf';
const String kSecret    = 'oiiFyoGgSQPAAcGCR1QNL85AgJp4XNXN';

const String kAuthHeader = 'Device $kDeviceID:$kToken:$kSecret';
const String kBaseUrl    = 'https://api.netpie.io/v2/device';

class MqttService extends ChangeNotifier {
  Timer? _timer;

  bool isConnected  = false;
  bool isConnecting = false;

  // ---- ค่าเซนเซอร์ ----
  int    smoke     = 0;
  int    vibration = 0;
  bool   doorOpen  = false;
  String status    = 'NORMAL';

  // ---- ตัวแปรควบคุม ----
  bool nightMode       = false;
  bool ledWhite1       = true;
  bool ledWhite2       = true;
  bool ledWhite3       = true;
  bool enableSmoke     = true;
  bool enableVibration = true;
  bool enableDoor      = true;

  Future<void> connect() async {
    if (isConnecting) return;
    isConnecting = true;
    notifyListeners();

    await _fetchShadow();

    // polling ทุก 2 วินาที
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchShadow());

    isConnecting = false;
    notifyListeners();
  }

  void disconnect() {
    _timer?.cancel();
    isConnected = false;
    notifyListeners();
  }

  Future<void> _fetchShadow() async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/shadow/data'),
        headers: {'Authorization': kAuthHeader},
      );
      debugPrint('Status: ${res.statusCode}');
      debugPrint('Body: ${res.body}');
      if (res.statusCode == 200) {
        final Map<String, dynamic> full = jsonDecode(res.body);
        final Map<String, dynamic> d    = full['data'] ?? full;
        smoke     = (d['smoke']     ?? smoke).toInt();
        vibration = (d['vibration'] ?? vibration).toInt();
        doorOpen  = _b(d['door'],            doorOpen);
        status    =  d['status']             ?? status;
        nightMode = _b(d['nightMode'],        nightMode);
        ledWhite1 = _b(d['ledWhite1'],        ledWhite1);
        ledWhite2 = _b(d['ledWhite2'],        ledWhite2);
        ledWhite3 = _b(d['ledWhite3'],        ledWhite3);
        enableSmoke     = _b(d['enableSmoke'],     enableSmoke);
        enableVibration = _b(d['enableVibration'], enableVibration);
        enableDoor      = _b(d['enableDoor'],      enableDoor);
        isConnected = true;
        notifyListeners();
      } else {
        isConnected = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
      isConnected = false;
      notifyListeners();
    }
  }

  Future<void> publish(String topic, String msg) async {
  try {
    final res = await http.put(
      Uri.parse('$kBaseUrl/message?topic=${Uri.encodeComponent(topic)}'),
      headers: {
        'Authorization': kAuthHeader,
        'Content-Type': 'application/json',
      },
      body: msg,
    );

    debugPrint('Publish status: ${res.statusCode}');
    debugPrint('Publish body: ${res.body}');
  } catch (e) {
    debugPrint('Publish error: $e');
  }
}

  bool _b(dynamic val, bool fallback) {
    if (val == null) return fallback;
    if (val is bool) return val;
    return val == 1;
  }

  void setLed(String which, bool val)     => publish('@msg/led/$which',    val ? 'on' : 'off');
  void setMode(bool night)                => publish('@msg/mode',           night ? 'night' : 'day');
  void setSensor(String sensor, bool val) => publish('@msg/enable/$sensor', val ? 'on' : 'off');
}