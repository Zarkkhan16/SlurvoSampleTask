import 'package:equatable/equatable.dart';
class TargetZoneConfig extends Equatable {
  final int targetDistance; // 60-150 yds
  final int difficulty; // 7, 5, or 3 (tolerance range)
  final int totalShots; // 1-10 or -1 for unlimited

  const TargetZoneConfig({
    required this.targetDistance,
    required this.difficulty,
    required this.totalShots,
  });

  int get tolerance => difficulty;

  int get minDistance => targetDistance - (tolerance ~/ 2);
  int get maxDistance => targetDistance + (tolerance ~/ 2);

  @override
  List<Object?> get props => [targetDistance, difficulty, totalShots];
}