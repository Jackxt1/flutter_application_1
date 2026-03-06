// lib/services/mqtt_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

// ============================================================
// ⚙️  NETPIE CONFIG — แก้ตรงนี้
// ============================================================
const String kMqttHost   = 'broker.netpie.io';
const int    kMqttPort   = 1883;
const int    kMqttWsPort = 8083;
const String kClientID   = 'cd843c79-b2ff-48f6-bc6c-8bc691fa7ff6-app';
const String kMqttUser   = 'xqweDbQFYALULNZXWypjTPdqm5bGPqEf';
const String kMqttPass   = 'oiiFyoGgSQPAAcGCR1QNL85AgJp4XNXN';

class MqttService extends ChangeNotifier {
  MqttClient? _client;

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
    isConnected  = false;
    notifyListeners();

    if (kIsWeb) {
      _client = MqttBrowserClient('ws://$kMqttHost:$kMqttWsPort/mqtt', kClientID)
        ..port            = kMqttWsPort
        ..keepAlivePeriod = 30
        ..onConnected     = _onConnected
        ..onDisconnected  = _onDisconnected
        ..logging(on: false);
    } else {
      _client = MqttServerClient(kMqttHost, kClientID)
        ..port            = kMqttPort
        ..keepAlivePeriod = 30
        ..onConnected     = _onConnected
        ..onDisconnected  = _onDisconnected
        ..logging(on: false);
    }

    _client!.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(kClientID)
        .authenticateAs(kMqttUser, kMqttPass)
        .startClean();

    try {
      await _client!.connect();
    } catch (e) {
      debugPrint('MQTT error: $e');
      isConnecting = false;
      notifyListeners();
      return;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.subscribe('@shadow/data', MqttQos.atLeastOnce);
      _client!.updates!.listen(_onMessage);
      publish('@shadow/data/get', '{}');
    }

    isConnecting = false;
    notifyListeners();
  }

  void disconnect() {
    _client?.disconnect();
    isConnected = false;
    notifyListeners();
  }

  void _onConnected()    { isConnected = true;  notifyListeners(); }
  void _onDisconnected() { isConnected = false; isConnecting = false; notifyListeners(); }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> msgs) {
    for (final m in msgs) {
      final raw = (m.payload as MqttPublishMessage).payload.message;
      try {
        final Map<String, dynamic> full = jsonDecode(utf8.decode(raw));
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
        notifyListeners();
      } catch (_) {}
    }
  }

  bool _b(dynamic val, bool fallback) {
    if (val == null) return fallback;
    if (val is bool) return val;
    return val == 1;
  }

  void publish(String topic, String msg) {
    if (_client == null) return;
    if (!isConnected && topic != '@shadow/data/get') return;
    final b = MqttClientPayloadBuilder()..addString(msg);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, b.payload!);
  }

  void setLed(String which, bool val)     => publish('@msg/led/$which',     val ? 'on' : 'off');
  void setMode(bool night)                => publish('@msg/mode',            night ? 'night' : 'day');
  void setSensor(String sensor, bool val) => publish('@msg/enable/$sensor', val ? 'on' : 'off');
}
