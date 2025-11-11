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
  List<Object?> get props => [shortestDistance, longestDistance, difficulty, increment, customIncrement, players];
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