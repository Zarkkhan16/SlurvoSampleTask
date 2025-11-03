import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../domain/entities/ble_device_entity.dart';
import '../../domain/repositories/ble_management_repository.dart';
import '../services/ble_management_service.dart';

class BleManagementRepositoryImpl implements BleManagementRepository {
  final BleManagementService _service;

  // Store last scanned devices to get name when connecting
  final Map<String, String> _deviceNames = {};

  BleManagementRepositoryImpl(this._service);

  @override
  Stream<BleStatus> get bleStatusStream => _service.statusStream;

  @override
  Stream<BleDeviceEntity> scanForDevices() {
    return _service.scanForDevices().map((device) {
      // Store device name for later use
      if (device.name.isNotEmpty) {
        _deviceNames[device.id] = device.name;
        print('📱 Found device: ${device.name} (${device.id})');
      }

      return BleDeviceEntity(
        id: device.id,
        name: device.name,
        rssi: device.rssi,
      );
    });
  }

  @override
  void stopScan() {
    _service.stopScan();
  }

  @override
  Stream<DeviceConnectionState> connectToDevice(String deviceId) {
    // Get device name from stored map
    final deviceName = _deviceNames[deviceId] ?? deviceId;
    print('🔗 Repository: Connecting to $deviceName ($deviceId)');

    return _service.connectToDevice(deviceId, deviceName);
  }

  @override
  Future<void> disconnect() {
    return _service.disconnect();
  }

  @override
  Future<void> discoverServices(String deviceId) {
    return _service.discoverServices(deviceId);
  }

  @override
  bool get isConnected => _service.isConnected;

  @override
  String? get connectedDeviceId => _service.connectedDeviceId;

  @override
  String? get connectedDeviceName => _service.connectedDeviceName;

  @override
  Stream<List<int>> subscribeToNotifications() {
    return _service.subscribeToNotifications();
  }

  @override
  Future<void> writeData(List<int> data) {
    return _service.writeData(data);
  }
}