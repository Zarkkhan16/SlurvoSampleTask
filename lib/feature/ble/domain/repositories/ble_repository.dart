import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_service.dart';

abstract class BleRepository {
  Stream<List<BleDevice>> scanForDevices();
  Future<bool> connectToDevice(String deviceId);
  Future<bool> disconnectDevice(String deviceId);
  Future< List<BleService>> discoverServices(String deviceId);
  Future<List<int>> readCharacteristic(
      String deviceId,
      String serviceUuid,
      String characteristicUuid,
      );
  Future<bool> writeCharacteristic(
      String deviceId,
      String serviceUuid,
      String characteristicUuid,
      List<int> data,
      );
  Stream<List<int>> subscribeToCharacteristic(
      String deviceId,
      String serviceUuid,
      String characteristicUuid,
      );
}