
import 'package:equatable/equatable.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/data/model/target_zone_config.dart';

abstract class TargetZoneEvent extends Equatable {
  const TargetZoneEvent();

  @override
  List<Object?> get props => [];
}

// Setup events
class TargetDistanceChanged extends TargetZoneEvent {
  final int distance;

  const TargetDistanceChanged(this.distance);

  @override
  List<Object?> get props => [distance];
}

class DifficultyChanged extends TargetZoneEvent {
  final int difficulty; // 7, 5, or 3

  const DifficultyChanged(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

class ShotCountChanged extends TargetZoneEvent {
  final int shotCount; // 1-10 or -1 for unlimited

  const ShotCountChanged(this.shotCount);

  @override
  List<Object?> get props => [shotCount];
}

class StartGameEvent extends TargetZoneEvent {
  final TargetZoneConfig config;

  const StartGameEvent(this.config);

  @override
  List<Object?> get props => [config];
}

// In-game events
class ShotRecordedEvent extends TargetZoneEvent {
  final int actualCarry;

  const ShotRecordedEvent(this.actualCarry);

  @override
  List<Object?> get props => [actualCarry];
}

class UndoLastShotEvent extends TargetZoneEvent {
  const UndoLastShotEvent();
}

class FinishSessionEvent extends TargetZoneEvent {
  const FinishSessionEvent();
}

class RestartSessionEvent extends TargetZoneEvent {
  const RestartSessionEvent();
}

// Reset
class ResetGameEvent extends TargetZoneEvent {
  const ResetGameEvent();
}

class BleDataReceivedEvent extends TargetZoneEvent {
  final List<int> data;

  BleDataReceivedEvent(this.data);

  @override
  List<Object> get props => [data];
}