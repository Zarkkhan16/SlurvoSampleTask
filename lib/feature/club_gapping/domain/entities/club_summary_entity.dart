import 'package:equatable/equatable.dart';

import 'club_entity.dart';
import 'shot_entity.dart';

class ClubSummaryEntity extends Equatable {
  final ClubEntity club;
  final List<ShotEntity> shots;
  final double averageCarryDistance;
  final double averageTotalDistance;
  final double averageClubSpeed;
  final double averageBallSpeed;
  final double averageSmashFactor;

  const ClubSummaryEntity({
    required this.club,
    required this.shots,
    required this.averageCarryDistance,
    required this.averageTotalDistance,
    required this.averageClubSpeed,
    required this.averageBallSpeed,
    required this.averageSmashFactor,
  });

  factory ClubSummaryEntity.fromShots(ClubEntity club, List<ShotEntity> shots) {
    if (shots.isEmpty) {
      return ClubSummaryEntity(
        club: club,
        shots: shots,
        averageCarryDistance: 0.0,
        averageTotalDistance: 0.0,
        averageClubSpeed: 0.0,
        averageBallSpeed: 0.0,
        averageSmashFactor: 0.0,
      );
    }

    return ClubSummaryEntity(
      club: club,
      shots: shots,
      averageCarryDistance: shots.fold<double>(
        0.0,
            (sum, shot) => sum + shot.carryDistance,
      ) /
          shots.length,
      averageTotalDistance: shots.fold<double>(
        0.0,
            (sum, shot) => sum + shot.totalDistance,
      ) /
          shots.length,
      averageClubSpeed: shots.fold<double>(
        0.0,
            (sum, shot) => sum + shot.clubSpeed,
      ) /
          shots.length,
      averageBallSpeed: shots.fold<double>(
        0.0,
            (sum, shot) => sum + shot.ballSpeed,
      ) /
          shots.length,
      averageSmashFactor: shots.fold<double>(
        0.0,
            (sum, shot) => sum + shot.smashFactor,
      ) /
          shots.length,
    );
  }

  @override
  List<Object?> get props => [
    club,
    shots,
    averageCarryDistance,
    averageTotalDistance,
    averageClubSpeed,
    averageBallSpeed,
    averageSmashFactor,
  ];
}