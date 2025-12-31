import 'package:equatable/equatable.dart';
import '../../data/model/target_zone_session.dart';

abstract class TargetZoneState extends Equatable {
  const TargetZoneState();

  @override
  List<Object?> get props => [];
}

class TargetZoneSetupState extends TargetZoneState {
  final int targetDistance;
  final int difficulty;
  final int shotCount;

  const TargetZoneSetupState({
    required this.targetDistance,
    required this.difficulty,
    required this.shotCount,
  });

  TargetZoneSetupState copyWith({
    int? targetDistance,
    int? difficulty,
    int? shotCount,
  }) {
    return TargetZoneSetupState(
      targetDistance: targetDistance ?? this.targetDistance,
      difficulty: difficulty ?? this.difficulty,
      shotCount: shotCount ?? this.shotCount,
    );
  }

  @override
  List<Object?> get props => [targetDistance, difficulty, shotCount];
}

// Game in progress
class TargetZoneGameState extends TargetZoneState {
  final TargetZoneSession session;
  final bool isWaitingForShot;

  const TargetZoneGameState({
    required this.session,
    this.isWaitingForShot = true,
  });

  // Calculated properties
  int get totalAttempts => session.totalAttempts;

  int get attemptsWithinTarget => session.attemptsWithinTarget;

  double get successRate => session.successRate;

  int get targetDistance => session.config.targetDistance;

  int get tolerance => session.config.tolerance;

  double? get lastActualCarry {
    if (session.shots.isEmpty) return null;
    return session.shots.last.actualCarry;
  }

  bool get isLastShotWithinTarget {
    if (session.shots.isEmpty) return false;
    return session.shots.last.isWithinTarget;
  }

  bool get isGameComplete => session.isComplete;

  String get remainingShots {
    if (session.config.totalShots == -1) return 'Unlimited';
    return '${session.config.totalShots - session.shots.length}';
  }

  TargetZoneGameState copyWith({
    TargetZoneSession? session,
    bool? isWaitingForShot,
  }) {
    return TargetZoneGameState(
      session: session ?? this.session,
      isWaitingForShot: isWaitingForShot ?? this.isWaitingForShot,
    );
  }

  @override
  List<Object?> get props => [session, isWaitingForShot];
}

class TargetZoneSessionCompleteState extends TargetZoneState {
  final TargetZoneSession session;
  const TargetZoneSessionCompleteState(this.session);
  @override
  List<Object?> get props => [session];
}

// Error state
class TargetZoneErrorState extends TargetZoneState {
  final String message;

  const TargetZoneErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
