import 'package:sample_task/feature/home_screens/data/%20datasources/shot_local_data_source.dart';
import '../../domain/entities/shot_data.dart';
import '../../domain/repositories/shot_repository.dart';

class ShotRepositoryImpl implements ShotRepository {
  final ShotLocalDataSource localDataSource;

  ShotRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ShotData>> getShotData() async {
    return await localDataSource.getShotData();
  }

}
