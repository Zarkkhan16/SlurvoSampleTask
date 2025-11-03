
import '../repositories/ble_management_repository.dart';

class DiscoverServicesUseCase {
  final BleManagementRepository repository;

  DiscoverServicesUseCase(this.repository);

  Future<void> call(String deviceId) {
    return repository.discoverServices(deviceId);
  }
}