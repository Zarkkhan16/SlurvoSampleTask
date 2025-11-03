import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../entities/ble_device_entity.dart';

abstract class BleManagementRepository {
  /// Get BLE adapter status stream
  Stream<BleStatus> get bleStatusStream;

  /// Scan for BLE devices (filtered for OneGolf devices)
  Stream<BleDeviceEntity> scanForDevices();

  /// Stop scanning for devices
  void stopScan();

  /// Connect to a specific device
  Stream<DeviceConnectionState> connectToDevice(String deviceId);

  /// Disconnect from current device
  Future<void> disconnect();

  /// Discover services and characteristics
  Future<void> discoverServices(String deviceId);

  /// Check if device is currently connected
  bool get isConnected;

  /// Get connected device ID
  String? get connectedDeviceId;

  /// Get connected device name
  String? get connectedDeviceName;

  /// Subscribe to notifications from device
  Stream<List<int>> subscribeToNotifications();

  /// Write data to device
  Future<void> writeData(List<int> data);
}