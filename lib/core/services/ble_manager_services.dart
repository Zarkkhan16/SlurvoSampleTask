import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Global BLE Manager - Singleton pattern
/// Yeh service poori app me ek hi instance use hogi
class BleManagerService {
  // Singleton instance
  static final BleManagerService _instance = BleManagerService._internal();
  factory BleManagerService() => _instance;
  BleManagerService._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  // Connection state streams
  final _connectionStateController = StreamController<DeviceConnectionState>.broadcast();
  final _notificationController = StreamController<List<int>>.broadcast();
  final _deviceStatusController = StreamController<BleStatus>.broadcast();

  // Subscriptions
  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _notifySub;

  // Connection details
  Uuid? _serviceId;
  Uuid? _writeCharId;
  Uuid? _notifyCharId;
  bool? _useWriteWithResponse;
  String? _connectedDeviceId;
  DeviceConnectionState _currentConnectionState = DeviceConnectionState.disconnected;

  // Public getters
  Stream<DeviceConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<List<int>> get notificationStream => _notificationController.stream;
  Stream<BleStatus> get bleStatusStream => _deviceStatusController.stream;
  DeviceConnectionState get currentConnectionState => _currentConnectionState;
  bool get isConnected => _currentConnectionState == DeviceConnectionState.connected;
  String? get connectedDeviceId => _connectedDeviceId;
  int? get batteryLevel => _lastBatteryLevel;

  int? _lastBatteryLevel;

  /// Initialize BLE Manager
  void initialize() {
    _ble.statusStream.listen((status) {
      _deviceStatusController.add(status);
      print('🔵 BLE Status: $status');
    });
  }

  /// Scan for devices
  Stream<DiscoveredDevice> scanForDevices({
    List<Uuid> serviceIds = const [],
    ScanMode scanMode = ScanMode.lowLatency,
  }) {
    _scanSub?.cancel();
    return _ble.scanForDevices(
      withServices: serviceIds,
      scanMode: scanMode,
      requireLocationServicesEnabled: false,
    );
  }

  /// Stop scanning
  void stopScan() {
    _scanSub?.cancel();
    print('🛑 Scan stopped');
  }

  /// Connect to device
  Future<void> connectToDevice(String deviceId) async {
    if (_connectedDeviceId == deviceId && isConnected) {
      print('✅ Already connected to device: $deviceId');
      return;
    }

    // Disconnect previous device if any
    if (_connectedDeviceId != null && _connectedDeviceId != deviceId) {
      await disconnect();
    }

    print('🔄 Connecting to device: $deviceId');
    _connectedDeviceId = deviceId;

    _connectionSub?.cancel();
    _connectionSub = _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    ).listen(
          (connectionState) {
        _currentConnectionState = connectionState.connectionState;
        _connectionStateController.add(connectionState.connectionState);
        print('📡 Connection State: ${connectionState.connectionState}');

        if (connectionState.connectionState == DeviceConnectionState.connected) {
          _onDeviceConnected();
        } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
          _onDeviceDisconnected();
        }
      },
      onError: (error) {
        print('❌ Connection error: $error');
        _currentConnectionState = DeviceConnectionState.disconnected;
        _connectionStateController.add(DeviceConnectionState.disconnected);
      },
    );
  }

  /// Called when device is connected
  Future<void> _onDeviceConnected() async {
    try {
      print('✅ Device connected, discovering services...');
      await discoverServices();
      await subscribeToNotifications();
      print('✅ Ready to communicate');
    } catch (e) {
      print('❌ Setup error: $e');
    }
  }

  /// Called when device is disconnected
  void _onDeviceDisconnected() {
    print('🔴 Device disconnected');
    _notifySub?.cancel();
    _serviceId = null;
    _writeCharId = null;
    _notifyCharId = null;
  }

  /// Discover services
  Future<void> discoverServices() async {
    if (_connectedDeviceId == null) {
      throw Exception('No device connected');
    }

    try {
      final services = await _ble.discoverServices(_connectedDeviceId!);
      print('🔍 Discovered ${services.length} services');

      for (var service in services) {
        print('   Service: ${service.serviceId}');

        // Golf device specific service UUID
        if (service.serviceId.toString().toLowerCase().contains("ffe0")) {
          _serviceId = service.serviceId;
          print('   ✅ Found target service: $_serviceId');

          for (var c in service.characteristics) {
            String charId = c.characteristicId.toString().toLowerCase();
            print('      Characteristic: $charId');

            // Notify characteristic
            if (charId.contains("fee2") && c.isNotifiable) {
              _notifyCharId = c.characteristicId;
              print('      ✅ Found notify char: $_notifyCharId');
            }

            // Write characteristic
            if (charId.contains("fee1") &&
                (c.isWritableWithResponse || c.isWritableWithoutResponse)) {
              _writeCharId = c.characteristicId;
              _useWriteWithResponse = c.isWritableWithResponse;
              print('      ✅ Found write char: $_writeCharId');
            }
          }
        }
      }

      if (_serviceId == null || _writeCharId == null || _notifyCharId == null) {
        throw Exception('Required characteristics not found');
      }
    } catch (e) {
      print('❌ Service discovery error: $e');
      throw Exception('Service discovery error: $e');
    }
  }

  /// Subscribe to notifications
  Future<void> subscribeToNotifications() async {
    if (_serviceId == null || _notifyCharId == null || _connectedDeviceId == null) {
      throw Exception('Cannot subscribe: Service not discovered');
    }

    _notifySub?.cancel();
    _notifySub = _ble.subscribeToCharacteristic(
      QualifiedCharacteristic(
        serviceId: _serviceId!,
        characteristicId: _notifyCharId!,
        deviceId: _connectedDeviceId!,
      ),
    ).listen(
          (data) {
        print('📩 Received notification: ${data.length} bytes');
        _notificationController.add(data);

        // Extract battery level if present
        if (data.length >= 4 && data[0] == 0x47 && data[1] == 0x46) {
          _lastBatteryLevel = data[3];
        }
      },
      onError: (error) {
        print('❌ Notification error: $error');
      },
    );

    print('✅ Subscribed to notifications');
  }

  /// Write data to device
  Future<void> writeData(List<int> data) async {
    if (_serviceId == null || _writeCharId == null || _connectedDeviceId == null) {
      throw Exception('Cannot write: Not connected or service not discovered');
    }

    if (!isConnected) {
      throw Exception('Device not connected');
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

      print('✍️ Data written: ${data.length} bytes');
    } catch (e) {
      print('❌ Write error: $e');
      throw Exception('Write error: $e');
    }
  }

  /// Read data from device (if supported)
  Future<List<int>> readData() async {
    if (_serviceId == null || _notifyCharId == null || _connectedDeviceId == null) {
      throw Exception('Cannot read: Not connected or service not discovered');
    }

    try {
      final char = QualifiedCharacteristic(
        serviceId: _serviceId!,
        characteristicId: _notifyCharId!,
        deviceId: _connectedDeviceId!,
      );

      final result = await _ble.readCharacteristic(char);
      print('📖 Data read: ${result.length} bytes');
      return result;
    } catch (e) {
      print('❌ Read error: $e');
      throw Exception('Read error: $e');
    }
  }

  /// Disconnect from device
  Future<void> disconnect() async {
    print('🔌 Disconnecting...');
    _connectionSub?.cancel();
    _notifySub?.cancel();
    _scanSub?.cancel();

    _serviceId = null;
    _writeCharId = null;
    _notifyCharId = null;
    _connectedDeviceId = null;
    _currentConnectionState = DeviceConnectionState.disconnected;
    _lastBatteryLevel = null;

    _connectionStateController.add(DeviceConnectionState.disconnected);
    print('✅ Disconnected');
  }

  /// Dispose (app shutdown only)
  void dispose() {
    _connectionStateController.close();
    _notificationController.close();
    _deviceStatusController.close();
    disconnect();
  }
}