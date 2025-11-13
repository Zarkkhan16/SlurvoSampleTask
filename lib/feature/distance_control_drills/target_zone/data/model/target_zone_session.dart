import 'package:equatable/equatable.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/data/model/shot_result.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/data/model/target_zone_config.dart';
class TargetZoneSession extends Equatable {
  final TargetZoneConfig config;
  final List<ShotResult> shots;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;

  const TargetZoneSession({
    required this.config,
    this.shots = const [],
    required this.startTime,
    this.endTime,
    this.isActive = true,
  });

  // Calculate totals
  int get totalAttempts => shots.length;
  int get attemptsWithinTarget => shots.where((s) => s.isWithinTarget).length;
  double get successRate {
    if (shots.isEmpty) return 0;
    return (attemptsWithinTarget / shots.length) * 100;
  }

  bool get isComplete {
    if (config.totalShots == -1) return false; // Unlimited
    return shots.length >= config.totalShots;
  }

  TargetZoneSession copyWith({
    TargetZoneConfig? config,
    List<ShotResult>? shots,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
  }) {
    return TargetZoneSession(
      config: config ?? this.config,
      shots: shots ?? this.shots,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [config, shots, startTime, endTime, isActive];
}