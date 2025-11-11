import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/shot_data.dart';

class LevelData {
  final int level;
  final int targetDistance;
  final int minDistance;
  final int maxDistance;
  final List<ShotData> shots;
  final int attempts;
  final bool completed;

  LevelData({
    required this.level,
    required this.targetDistance,
    required this.minDistance,
    required this.maxDistance,
    required this.shots,
    required this.attempts,
    required this.completed,
  });
}