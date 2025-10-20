import 'package:onegolf/feature/golf_device/domain/entities/shot_anaylsis_entity.dart';

import '../repositories/ble_repository.dart';
class FetchShotsUseCase {
  final BleRepository repository;

  FetchShotsUseCase(this.repository);

  Future<List<ShotAnalysisEntity>> call(String userId) async {
    return await repository.fetchShotsForUser(userId);
  }
}
