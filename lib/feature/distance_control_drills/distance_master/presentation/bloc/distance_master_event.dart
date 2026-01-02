import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class DistanceMasterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeGameEvent extends DistanceMasterEvent {
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
  List<Object?> get props => [
        shortestDistance,
        longestDistance,
        difficulty,
        increment,
        customIncrement,
        players
      ];
}

class StartGameEvent extends DistanceMasterEvent {}

class ShotReceivedEvent extends DistanceMasterEvent {
  final double carryDistance;

  ShotReceivedEvent(this.carryDistance);

  @override
  List<Object> get props => [carryDistance];
}

class BleDataReceivedEvent extends DistanceMasterEvent {
  final List<int> data;

  BleDataReceivedEvent(this.data);

  @override
  List<Object> get props => [data];
}

class RetryCurrentLevelEvent extends DistanceMasterEvent {}

class EndSessionEvent extends DistanceMasterEvent {}

class RestartGameEvent extends DistanceMasterEvent {}

class UpdateShortestDistanceEvent extends DistanceMasterEvent {
  final int distance;

  UpdateShortestDistanceEvent(this.distance);

  @override
  List<Object> get props => [distance];
}

class UpdateLongestDistanceEvent extends DistanceMasterEvent {
  final int distance;

  UpdateLongestDistanceEvent(this.distance);

  @override
  List<Object> get props => [distance];
}

class UpdateDifficultyEvent extends DistanceMasterEvent {
  final int difficulty;

  UpdateDifficultyEvent(this.difficulty);

  @override
  List<Object> get props => [difficulty];
}

class UpdateIncrementEvent extends DistanceMasterEvent {
  final int increment;

  UpdateIncrementEvent(this.increment);

  @override
  List<Object> get props => [increment];
}

class UpdateCustomIncrementEvent extends DistanceMasterEvent {
  final int? customIncrement;

  UpdateCustomIncrementEvent(this.customIncrement);

  @override
  List<Object?> get props => [customIncrement];
}

class AddPlayerEvent extends DistanceMasterEvent {
  final String playerName;

  AddPlayerEvent(this.playerName);

  @override
  List<Object> get props => [playerName];
}

class RemovePlayerEvent extends DistanceMasterEvent {
  final int playerIndex;

  RemovePlayerEvent(this.playerIndex);

  @override
  List<Object> get props => [playerIndex];
}

class EditPlayerEvent extends DistanceMasterEvent {
  final int playerIndex;
  final String newName;

  EditPlayerEvent(this.playerIndex, this.newName);

  @override
  List<Object> get props => [playerIndex, newName];
}

class EndGameEvent extends DistanceMasterEvent {
  EndGameEvent();
}
