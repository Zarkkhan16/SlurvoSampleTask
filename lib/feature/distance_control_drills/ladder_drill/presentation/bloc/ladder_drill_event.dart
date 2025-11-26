import 'package:equatable/equatable.dart';

abstract class LadderDrillEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeGameEvent extends LadderDrillEvent {
  final int shortestDistance;
  final int longestDistance;
  final int difficulty;
  final int increment;
  final int? customIncrement;
  final List<String> players;

  InitializeGameEvent({
    required this.shortestDistance,
    required this.longestDistance,
    required this.difficulty,
    required this.increment,
    this.customIncrement,
    required this.players,
  });

  @override
  List<Object?> get props => [shortestDistance, longestDistance, difficulty, increment, customIncrement, players];
}

class StartGameEvent extends LadderDrillEvent {}

class UpdateShortestDistanceEvent extends LadderDrillEvent {
  final int distance;

  UpdateShortestDistanceEvent(this.distance);

  @override
  List<Object> get props => [distance];
}

class UpdateLongestDistanceEvent extends LadderDrillEvent {
  final int distance;

  UpdateLongestDistanceEvent(this.distance);

  @override
  List<Object> get props => [distance];
}

class UpdateDifficultyEvent extends LadderDrillEvent {
  final int difficulty;

  UpdateDifficultyEvent(this.difficulty);

  @override
  List<Object> get props => [difficulty];
}

class UpdateIncrementEvent extends LadderDrillEvent {
  final int increment;

  UpdateIncrementEvent(this.increment);

  @override
  List<Object> get props => [increment];
}

class UpdateCustomIncrementEvent extends LadderDrillEvent {
  final int? customIncrement;

  UpdateCustomIncrementEvent(this.customIncrement);

  @override
  List<Object?> get props => [customIncrement];
}

class AddPlayerEvent extends LadderDrillEvent {
  final String playerName;

  AddPlayerEvent(this.playerName);

  @override
  List<Object> get props => [playerName];
}

class RemovePlayerEvent extends LadderDrillEvent {
  final int playerIndex;

  RemovePlayerEvent(this.playerIndex);

  @override
  List<Object> get props => [playerIndex];
}

class EditPlayerEvent extends LadderDrillEvent {
  final int playerIndex;
  final String newName;

  EditPlayerEvent(this.playerIndex, this.newName);

  @override
  List<Object> get props => [playerIndex, newName];
}

// Game Progress Events
class ShotReceivedEvent extends LadderDrillEvent {
  final double carryDistance;

  ShotReceivedEvent(this.carryDistance);

  @override
  List<Object> get props => [carryDistance];
}

class BleDataReceivedEvent extends LadderDrillEvent {
  final List<int> data;

  BleDataReceivedEvent(this.data);

  @override
  List<Object> get props => [data];
}

class RetryCurrentLevelEvent extends LadderDrillEvent {}

class EndSessionEvent extends LadderDrillEvent {}

class RestartGameEvent extends LadderDrillEvent {}
class NextLevelEvent extends LadderDrillEvent {}