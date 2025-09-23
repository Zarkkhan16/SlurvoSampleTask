import '../../domain/entities/shot_data.dart';

class ShotDataModel extends ShotData {
   ShotDataModel({
    super.id,
    required super.value,
    required super.metric,
    required super.unit,
  });
}