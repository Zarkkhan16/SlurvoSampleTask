import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:onegolf/feature/ble/domain/entities/ble_characteristic.dart';
import 'package:onegolf/feature/ble/domain/entities/ble_device.dart';
import 'package:onegolf/feature/ble/domain/entities/ble_service.dart';
import 'package:onegolf/feature/ble/domain/repositories/ble_repository.dart';

class BleRepositoryImpl implements BleRepository {
  final Map<String, BluetoothDevice> _connectedDevices = {};

  @override
  Stream<List<BleDevice>> scanForDevices() async* {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      yield* FlutterBluePlus.scanResults.map((results) {
        return results.map((result) {
          return BleDevice(
            id: result.device.id.id,
            name: result.device.name.isEmpty
                ? 'Unknown Device'
                : result.device.name,
            type: 'BLE',
            rssi: result.rssi,
            isConnected: result.advertisementData.connectable,
          );
        }).toList();
      });
    } catch (e) {
      yield [];
    }
  }

  @override
  Future<bool> connectToDevice(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevices[deviceId] = device;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> disconnectDevice(String deviceId) async {
    try {
      final device = _connectedDevices[deviceId];
      if (device != null) {
        await device.disconnect();
        _connectedDevices.remove(deviceId);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<BleService>> discoverServices(String deviceId) async {
    try {
      final device = _connectedDevices[deviceId];
      if (device == null) return [];

      final services = await device.discoverServices();

      return services.map((service) {
        final characteristics = service.characteristics.map((char) {
          return BleCharacteristic(
            uuid: char.uuid.toString(),
            canRead: char.properties.read,
            canWrite: char.properties.write,
            canNotify: char.properties.notify,
          );
        }).toList();

        return BleService(
          uuid: service.uuid.toString(),
          characteristics: characteristics,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<int>> readCharacteristic(
    String deviceId,
    String serviceUuid,
    String characteristicUuid,
  ) async {
    try {
      final device = _connectedDevices[deviceId];
      if (device == null) return [];

      final services = await device.discoverServices();
      final service =
          services.firstWhere((s) => s.uuid.toString() == serviceUuid);
      final characteristic = service.characteristics
          .firstWhere((c) => c.uuid.toString() == characteristicUuid);

      return await characteristic.read();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> writeCharacteristic(
    String deviceId,
    String serviceUuid,
    String characteristicUuid,
    List<int> data,
  ) async {
    try {
      final device = _connectedDevices[deviceId];
      if (device == null) return false;

      final services = await device.discoverServices();
      final service =
          services.firstWhere((s) => s.uuid.toString() == serviceUuid);
      final characteristic = service.characteristics
          .firstWhere((c) => c.uuid.toString() == characteristicUuid);

      await characteristic.write(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<List<int>> subscribeToCharacteristic(
    String deviceId,
    String serviceUuid,
    String characteristicUuid,
  ) async* {
    try {
      final device = _connectedDevices[deviceId];
      if (device == null) throw Exception('Device not connected');

      final services = await device.discoverServices();
      final service =
          services.firstWhere((s) => s.uuid.toString() == serviceUuid);
      final characteristic = service.characteristics
          .firstWhere((c) => c.uuid.toString() == characteristicUuid);

      await characteristic.setNotifyValue(true);
      yield* characteristic.value;
    } catch (e) {
      yield* Stream<List<int>>.error(e);
    }
  }
}
