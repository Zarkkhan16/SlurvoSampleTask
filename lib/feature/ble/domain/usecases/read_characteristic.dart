import '../../../../core/usecases/usecase.dart';
import '../repositories/ble_repository.dart';

class ReadCharacteristic implements UseCase<List<int>, ReadCharacteristicParams> {
  final BleRepository repository;

  ReadCharacteristic(this.repository);

  @override
  Future<List<int>> call(ReadCharacteristicParams params) async {
    return await repository.readCharacteristic(
      params.deviceId,
      params.serviceUuid,
      params.characteristicUuid,
    );
  }
}

class ReadCharacteristicParams {
  final String deviceId;
  final String serviceUuid;
  final String characteristicUuid;

  ReadCharacteristicParams({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
  });
}
