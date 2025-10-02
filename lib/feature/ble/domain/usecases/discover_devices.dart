
import 'package:OneGolf/core/usecases/usecase.dart';
import 'package:OneGolf/feature/ble/domain/entities/ble_service.dart';
import 'package:OneGolf/feature/ble/domain/repositories/ble_repository.dart';



class DiscoverServices implements UseCase<List<BleService>, DiscoverServicesParams> {
  final BleRepository repository;

  DiscoverServices(this.repository);

  @override
  Future<List<BleService>> call(DiscoverServicesParams params) async {
    return await repository.discoverServices(params.deviceId);
  }
}

class DiscoverServicesParams {
  final String deviceId;

  DiscoverServicesParams({required this.deviceId});
}