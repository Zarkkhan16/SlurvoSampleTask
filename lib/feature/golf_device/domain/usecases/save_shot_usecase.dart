import 'package:onegolf/feature/golf_device/data/model/shot_anaylsis_model.dart';

import '../entities/shot_anaylsis_entity.dart';
import '../repositories/ble_repository.dart';

class SaveShotUseCase {
  final BleRepository repository;
  SaveShotUseCase(this.repository);

  Future<void> call(ShotAnalysisModel shot) async {
    return repository.saveShot(shot);
  }
}
