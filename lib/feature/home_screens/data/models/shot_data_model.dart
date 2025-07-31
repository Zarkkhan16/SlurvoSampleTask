import '../../domain/entities/shot_data.dart';

class ShotDataModel extends ShotData {
  const ShotDataModel({
    required super.id,
    required super.value,
    required super.metric,
    required super.unit,
  });
}