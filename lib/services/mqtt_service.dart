// lib/services/mqtt_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

const String kDeviceID    = '02df66d6-f1be-4893-93fa-280a5fdd9966';
const String kToken       = 'TA1tY8pw2Ey7RkB16nukR4LWYgQwJJuj';
const String kSecret      = 'Jywxyb6tM7UJeKjSZE8nuxkLBUCx4bfF';

const String kIotDeviceID = 'cd843c79-b2ff-48f6-bc6c-8bc691fa7ff6';
const String kIotToken    = 'xqweDbQFYALULNZXWypjTPdqm5bGPqEf';
const String kIotSecret   = 'oiiFyoGgSQPAAcGCR1QNL85AgJp4XNXN';

const String kAuthHeader  = 'Device $kIotDeviceID:$kIotToken:$kIotSecret';
const String kBaseUrl     = 'https://api.netpie.io/v2/device';

class MqttService extends ChangeNotifier {
  Timer? _timer;
  MqttServerClient? _mqttClient;

  bool isConnected  = false;
  bool isConnecting = false;

  int    smoke     = 0;
  int    vibration = 0;
  bool   doorOpen  = false;
  String status    = 'NORMAL';

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

    await _connectMqtt();
    await _fetchShadow();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchShadow());

    isConnecting = false;
    notifyListeners();
  }

  Future<void> _connectMqtt() async {
    try {
      debugPrint('Creating MQTT client...');
      _mqttClient = MqttServerClient('broker.netpie.io', kDeviceID)
        ..port = 1883
        ..keepAlivePeriod = 30
        ..logging(on: false);

      _mqttClient!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(kDeviceID)
          .authenticateAs(kToken, kSecret)
          .startClean();

      debugPrint('Connecting MQTT...');
      await _mqttClient!.connect();
      debugPrint('MQTT state: ${_mqttClient!.connectionStatus!.state}');
      debugPrint('MQTT return: ${_mqttClient!.connectionStatus!.returnCode}');
    } catch (e) {
      debugPrint('MQTT connect error: $e');
    }
  }

  void disconnect() {
    _timer?.cancel();
    _mqttClient?.disconnect();
    isConnected = false;
    notifyListeners();
  }

  Future<void> _fetchShadow() async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl/shadow/data'),
        headers: {'Authorization': kAuthHeader},
      );
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

  void publish(String topic, String msg) {
    try {
      debugPrint('Publishing: $topic = $msg');
      if (_mqttClient?.connectionStatus?.state == MqttConnectionState.connected) {
        final b = MqttClientPayloadBuilder()..addString(msg);
        _mqttClient!.publishMessage(topic, MqttQos.atLeastOnce, b.payload!);
        debugPrint('MQTT Published: $topic = $msg');
      } else {
        debugPrint('MQTT not connected, state: ${_mqttClient?.connectionStatus?.state}');
      }
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