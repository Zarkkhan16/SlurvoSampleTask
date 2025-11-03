
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';

class DisconnectDeviceUseCase {
  final BleManagementRepository repository;

  DisconnectDeviceUseCase(this.repository);

  Future<void> call() {
    return repository.disconnect();
  }
}