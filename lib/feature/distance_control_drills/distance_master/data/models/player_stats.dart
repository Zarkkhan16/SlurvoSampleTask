import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/level_data.dart';

class PlayerStats {
  final String playerName;
  final List<LevelData> levels;
  final int highestLevel;
  final double averageDistance;

  PlayerStats({
    required this.playerName,
    required this.levels,
    required this.highestLevel,
    required this.averageDistance,
  });
}