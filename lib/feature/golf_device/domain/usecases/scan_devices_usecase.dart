import 'package:onegolf/feature/golf_device/domain/entities/device_entity.dart';
import '../repositories/ble_repository.dart';

class ScanDevicesUseCase {
  final BleRepository repository;

  ScanDevicesUseCase(this.repository);

  Stream<DeviceEntity> call() {
    return repository.scanForDevices();
  }

  void stop() {
    repository.stopScan();
  }
}