import '../repositories/ble_management_repository.dart';

class CheckConnectionStatusUseCase {
  final BleManagementRepository repository;

  CheckConnectionStatusUseCase(this.repository);

  bool call() {
    return repository.isConnected;
  }

  String? getConnectedDeviceId() {
    return repository.connectedDeviceId;
  }

  String? getConnectedDeviceName() {
    return repository.connectedDeviceName;
  }
}