import 'package:OneGolf/core/usecases/usecase.dart';
import '../entities/shot_data.dart';
import '../repositories/shot_repository.dart';

class GetShotData implements UseCase<List<ShotData>, NoParams> {
  final ShotRepository repository;

  GetShotData(this.repository);

  @override
  Future<List<ShotData>> call(NoParams params) async {
    return await repository.getShotData();
  }
}
