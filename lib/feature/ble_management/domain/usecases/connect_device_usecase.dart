import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../repositories/ble_management_repository.dart';

class ConnectDeviceUseCase {
  final BleManagementRepository repository;

  ConnectDeviceUseCase(this.repository);

  Stream<DeviceConnectionState> call(String deviceId) {
    return repository.connectToDevice(deviceId);
  }
}