import '../../../../core/usecases/usecase.dart';
import '../repositories/ble_repository.dart';

class ConnectToDevice implements UseCase<bool, ConnectToDeviceParams> {
  final BleRepository repository;

  ConnectToDevice(this.repository);

  @override
  Future<bool> call(ConnectToDeviceParams params) async {
    return await repository.connectToDevice(params.deviceId);
  }
}

class ConnectToDeviceParams {
  final String deviceId;

  ConnectToDeviceParams({required this.deviceId});
}