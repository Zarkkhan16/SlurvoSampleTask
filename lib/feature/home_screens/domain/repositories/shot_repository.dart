import '../entities/shot_data.dart';

abstract class ShotRepository {
  Future<List<ShotData>> getShotData();
}
