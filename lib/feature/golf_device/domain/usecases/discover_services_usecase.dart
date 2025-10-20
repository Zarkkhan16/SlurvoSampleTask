import '../repositories/ble_repository.dart';
class DiscoverServicesUseCase {
  final BleRepository repository;

  DiscoverServicesUseCase(this.repository);

  Future<void> call(String deviceId) {
    return repository.discoverServices(deviceId);
  }
}