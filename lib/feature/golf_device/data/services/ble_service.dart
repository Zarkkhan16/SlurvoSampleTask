import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _notifySub;

  Uuid? _serviceId;
  Uuid? _writeCharId;
  Uuid? _notifyCharId;
  bool? _useWriteWithResponse;
  String? _connectedDeviceId;

  Stream<BleStatus> get statusStream => _ble.statusStream;

  Stream<DiscoveredDevice> scanForDevices() {
    _scanSub?.cancel();
    return _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: false,
    );
  }

  void stopScan() {
    _scanSub?.cancel();
  }

  Stream<DeviceConnectionState> connectToDevice(String deviceId) {
    _connectedDeviceId = deviceId;
    _connectionSub?.cancel();
    return _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: Duration(seconds: 10),
    ).map((update) => update.connectionState);
  }

  Future<void> discoverServices(String deviceId) async {
    try {
      final services = await _ble.discoverServices(deviceId);

      for (var service in services) {
        if (service.serviceId.toString().toLowerCase().contains("ffe0")) {
          _serviceId = service.serviceId;

          for (var c in service.characteristics) {
            String charId = c.characteristicId.toString().toLowerCase();

            if (charId.contains("fee2") && c.isNotifiable) {
              _notifyCharId = c.characteristicId;
            }

            if (charId.contains("fee1") &&
                (c.isWritableWithResponse || c.isWritableWithoutResponse)) {
              _writeCharId = c.characteristicId;
              _useWriteWithResponse = c.isWritableWithResponse;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Service discovery error: $e');
    }
  }

  Stream<List<int>> subscribeToNotifications() {
    if (_serviceId == null || _notifyCharId == null || _connectedDeviceId == null) {
      throw Exception('Cannot subscribe: Service not discovered');
    }

    _notifySub?.cancel();
    return _ble.subscribeToCharacteristic(
      QualifiedCharacteristic(
        serviceId: _serviceId!,
        characteristicId: _notifyCharId!,
        deviceId: _connectedDeviceId!,
      ),
    );
  }

  Future<void> writeData(List<int> data) async {
    if (_serviceId == null || _writeCharId == null || _connectedDeviceId == null) {
      throw Exception('Cannot write: Not connected or service not discovered');
    }

    try {
      final char = QualifiedCharacteristic(
        serviceId: _serviceId!,
        characteristicId: _writeCharId!,
        deviceId: _connectedDeviceId!,
      );

      if (_useWriteWithResponse == true) {
        await _ble.writeCharacteristicWithResponse(char, value: data);
      } else {
        await _ble.writeCharacteristicWithoutResponse(char, value: data);
      }
    } catch (e) {
      throw Exception('Write error: $e');
    }
  }

  Future<void> disconnect() async {
    _scanSub?.cancel();
    _connectionSub?.cancel();
    _notifySub?.cancel();
    _serviceId = null;
    _writeCharId = null;
    _notifyCharId = null;
    _connectedDeviceId = null;
  }

  void dispose() {
    disconnect();
  }
}
