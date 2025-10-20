// lib/core/helpers/ble_helper.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../demoapp.dart';
import '../../feature/home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';

class BleHelper {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  DiscoveredDevice? connectedDevice;
  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;

  final List<DiscoveredDevice> devices = [];

  final _logController = StreamController<String>.broadcast();
  final _golfDataController = StreamController<GolfData>.broadcast();

  Stream<String> get logs => _logController.stream;
  Stream<GolfData> get golfDataStream => _golfDataController.stream;

  // UUIDs
  static const String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String writeUuid   = "0000fee1-0000-1000-8000-00805f9b34fb";
  static const String notifyUuid  = "0000fee2-0000-1000-8000-00805f9b34fb";

  void startScan() {
    devices.clear();
    _scanSub?.cancel();
    _scanSub = _ble.scanForDevices(withServices: []).listen((device) {
      if (device.name.isNotEmpty &&
          (device.name.startsWith("A-1LM-") || device.name.contains("BM"))) {
        if (devices.indexWhere((d) => d.id == device.id) == -1) {
          devices.add(device);
        }
      }
    }, onError: (e) {
      _log("Scan error: $e");
    });
  }

  void stopScan() {
    _scanSub?.cancel();
  }

  void connect(DiscoveredDevice device) {
    _connSub?.cancel();
    _connSub = _ble.connectToDevice(id: device.id).listen((update) {
      connectionState = update.connectionState;
      if (update.connectionState == DeviceConnectionState.connected) {
        connectedDevice = device;
        _discoverServices(device.id);
      }
    }, onError: (e) {
      _log("Connection error: $e");
    });
  }

  void disconnect() {
    _connSub?.cancel();
    _notifySub?.cancel();
    connectedDevice = null;
    connectionState = DeviceConnectionState.disconnected;
  }

  Future<void> _discoverServices(String deviceId) async {
    final services = await _ble.discoverServices(deviceId);
    for (var s in services) {
      _log("Service: ${s.serviceId}");
    }

    final notifyChar = QualifiedCharacteristic(
      serviceId: Uuid.parse(serviceUuid),
      characteristicId: Uuid.parse(notifyUuid),
      deviceId: deviceId,
    );

    _notifySub = _ble.subscribeToCharacteristic(notifyChar).listen((data) {
      if (data.isNotEmpty) {
        _parseGolfData(Uint8List.fromList(data));
      }
    }, onError: (e) => _log("Notify error: $e"));
  }

  Future<void> sendCommand(int cmd, int param1, int param2) async {
    // if (connectedDevice == null || connectionState != DeviceConnectionState.connected) return;

    List<int> packet = [0x47, 0x46, cmd, param1, param2];
    int checksum = 0;
    for (int i = 2; i < packet.length; i++) {
      checksum += packet[i];
    }
    packet.add(checksum & 0xFF);
    write(packet);
  }
  Future<void> write(List<int> data) async {
    if (connectedDevice == null) return;
    final writeChar = QualifiedCharacteristic(
      serviceId: Uuid.parse(serviceUuid),
      characteristicId: Uuid.parse(writeUuid),
      deviceId: connectedDevice!.id,
    );
    await _ble.writeCharacteristicWithoutResponse(writeChar, value: data);
    _log("Write -> $data");
  }

  void _parseGolfData(Uint8List data) {
    if (data.length < 15 || data[0] != 0x47 || data[1] != 0x46) return;

    final golfData = GolfData()
      ..battery       = data[3]
      ..recordNumber  = (data[4] << 8) | data[5]
      ..clubName      = data[6]
      ..clubSpeed     = ((data[7] << 8) | data[8]) / 10.0
      ..ballSpeed     = ((data[9] << 8) | data[10]) / 10.0
      ..carryDistance = ((data[11] << 8) | data[12]) / 10.0
      ..totalDistance = ((data[13] << 8) | data[14]) / 10.0;

    // batteryNotifier.value = golfData.battery;
    _golfDataController.add(golfData);
  }

  void _log(String msg) {
    _logController.add("[${DateTime.now()}] $msg");
    print(msg);
  }

  void dispose() {
    _scanSub?.cancel();
    _connSub?.cancel();
    _notifySub?.cancel();
    _logController.close();
    _golfDataController.close();
  }
}
