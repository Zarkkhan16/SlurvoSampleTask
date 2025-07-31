import '../../../../core/usecases/usecase.dart';
import '../repositories/ble_repository.dart';

class WriteCharacteristic implements UseCase<bool, WriteCharacteristicParams> {
  final BleRepository repository;

  WriteCharacteristic(this.repository);

  @override
  Future< bool> call(WriteCharacteristicParams params) async {
    return await repository.writeCharacteristic(
      params.deviceId,
      params.serviceUuid,
      params.characteristicUuid,
      params.data,
    );
  }
}

class WriteCharacteristicParams {
  final String deviceId;
  final String serviceUuid;
  final String characteristicUuid;
  final List<int> data;

  WriteCharacteristicParams({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.data,
  });
}
