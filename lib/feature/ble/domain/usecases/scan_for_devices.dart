import 'package:sample_task/feature/ble/domain/entities/ble_device.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/ble_repository.dart';

class ScanForDevices implements StreamUseCase<List<BleDevice>, NoParams> {
  final BleRepository repository;

  ScanForDevices(this.repository);

  @override
  Stream<List<BleDevice>> call(NoParams params) {
    return repository.scanForDevices();
  }
}
