import '../repositories/ble_repository.dart';

class DeleteShotUseCase {
  final BleRepository repository;

  DeleteShotUseCase(this.repository);

  Future<void> call(String userId, String shotId) async {
    await repository.deleteShot(userId, shotId);
  }
}
