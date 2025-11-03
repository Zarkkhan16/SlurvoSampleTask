import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleManagementService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _notifySub;

  Uuid? _serviceId;
  Uuid? _writeCharId;
  Uuid? _notifyCharId;
  bool? _useWriteWithResponse;
  String? _connectedDeviceId;
  String? _connectedDeviceName;
  bool _isConnected = false;

  Stream<BleStatus> get statusStream => _ble.statusStream;
  bool get isConnected => _isConnected;
  String? get connectedDeviceId => _connectedDeviceId;
  String? get connectedDeviceName => _connectedDeviceName;

  /// Scan for devices with filter for OneGolf devices
  Stream<DiscoveredDevice> scanForDevices() {
    _scanSub?.cancel();
    return _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: false,
    ).where((device) {
      // Filter for OneGolf devices only
      return device.name.isNotEmpty &&
          (device.name.startsWith("A-1LM-") || device.name.contains("BM"));
    });
  }

  void stopScan() {
    _scanSub?.cancel();
  }

  Stream<DeviceConnectionState> connectToDevice(
      String deviceId, String deviceName) {
    print('🔵 BleManagementService: Connecting to device...');
    print('   Device ID: $deviceId');
    print('   Device Name: $deviceName');

    // IMPORTANT: Store device info IMMEDIATELY
    _connectedDeviceId = deviceId;
    _connectedDeviceName = deviceName;

    _connectionSub?.cancel();

    return _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: Duration(seconds: 10),
    )
        .map((update) {
      print('🔵 Connection state update: ${update.connectionState}');

      // Update connection status based on state
      if (update.connectionState == DeviceConnectionState.connected) {
        _isConnected = true;
        print('✅ Device connected successfully!');
        print('   Stored Device ID: $_connectedDeviceId');
        print('   Stored Device Name: $_connectedDeviceName');
        print('   Is Connected: $_isConnected');
      } else if (update.connectionState == DeviceConnectionState.disconnected) {
        _isConnected = false;
        print('❌ Device disconnected');
        // Don't clear device info on disconnect - keep it for potential reconnect
      }

      return update.connectionState;
    });
  }

  Future<void> discoverServices(String deviceId) async {
    print('🔍 Discovering services for device: $deviceId');

    try {
      final services = await _ble.discoverServices(deviceId);

      for (var service in services) {
        // Look for service FFE0
        if (service.serviceId.toString().toLowerCase().contains("ffe0")) {
          _serviceId = service.serviceId;
          print('✅ Found service: ${service.serviceId}');

          for (var c in service.characteristics) {
            String charId = c.characteristicId.toString().toLowerCase();

            // Notify characteristic FEE2
            if (charId.contains("fee2") && c.isNotifiable) {
              _notifyCharId = c.characteristicId;
              print('✅ Found notify characteristic: ${c.characteristicId}');
            }

            // Write characteristic FEE1
            if (charId.contains("fee1") &&
                (c.isWritableWithResponse || c.isWritableWithoutResponse)) {
              _writeCharId = c.characteristicId;
              _useWriteWithResponse = c.isWritableWithResponse;
              print('✅ Found write characteristic: ${c.characteristicId}');
            }
          }
        }
      }

      if (_serviceId == null || _writeCharId == null || _notifyCharId == null) {
        throw Exception('Required characteristics not found');
      }

      print('✅ Service discovery completed successfully');
    } catch (e) {
      print('❌ Service discovery error: $e');
      throw Exception('Service discovery error: $e');
    }
  }

  Stream<List<int>> subscribeToNotifications() {
    if (_serviceId == null ||
        _notifyCharId == null ||
        _connectedDeviceId == null) {
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
    if (_serviceId == null ||
        _writeCharId == null ||
        _connectedDeviceId == null) {
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
    print('🔴 BleManagementService: Disconnecting...');

    _scanSub?.cancel();
    _connectionSub?.cancel();
    _notifySub?.cancel();
    _serviceId = null;
    _writeCharId = null;
    _notifyCharId = null;

    // Clear connection info
    _connectedDeviceId = null;
    _connectedDeviceName = null;
    _isConnected = false;

    print('✅ Disconnected successfully');
  }

  void dispose() {
    disconnect();
  }
}