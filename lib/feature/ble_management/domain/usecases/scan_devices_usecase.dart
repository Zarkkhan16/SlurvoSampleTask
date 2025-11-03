import 'package:onegolf/feature/golf_device/domain/entities/device_entity.dart';
import '../entities/ble_device_entity.dart';
import '../repositories/ble_management_repository.dart';

class ScanDevicesUseCase {
  final BleManagementRepository repository;

  ScanDevicesUseCase(this.repository);

  Stream<BleDeviceEntity> call() {
    return repository.scanForDevices();
  }

  void stop() {
    repository.stopScan();
  }
}