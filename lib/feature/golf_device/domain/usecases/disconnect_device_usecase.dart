import '../repositories/ble_repository.dart';
class DisconnectDeviceUseCase {
  final BleRepository repository;

  DisconnectDeviceUseCase(this.repository);

  Future<void> call() {
    return repository.disconnect();
  }
}