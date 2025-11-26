import 'package:equatable/equatable.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/level_data.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/player_stats.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/shot_data.dart';

abstract class LadderDrillState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DistanceMasterInitial extends LadderDrillState {}

class GameSetupState extends LadderDrillState {
  final int shortestDistance;
  final int longestDistance;
  final int difficulty;
  final int increment;
  final int? customIncrement;
  final List<String> players;
  final String? errorMessage;
  final int maxPlayers;


  GameSetupState({
    this.shortestDistance = 60,
    this.longestDistance = 80,
    this.difficulty = 7,
    this.increment = 5,
    this.customIncrement,
    List<String>? players,
    this.errorMessage,
    this.maxPlayers = 4,
  }) : players = players ?? [AppStrings.userProfileData.name];

  GameSetupState copyWith({
    int? shortestDistance,
    int? longestDistance,
    int? difficulty,
    int? increment,
    int? customIncrement,
    List<String>? players,
    String? errorMessage,
  }) {
    return GameSetupState(
      shortestDistance: shortestDistance ?? this.shortestDistance,
      longestDistance: longestDistance ?? this.longestDistance,
      difficulty: difficulty ?? this.difficulty,
      increment: increment ?? this.increment,
      customIncrement: customIncrement ?? this.customIncrement,
      players: players ?? this.players,
      maxPlayers: maxPlayers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [shortestDistance, longestDistance, difficulty, increment, customIncrement, players, errorMessage];
}

class GameInProgressState extends LadderDrillState {
  final int currentLevel;
  final int totalLevels;
  final int targetDistance;
  final int toleranceWindow;
  final int minDistance;
  final int maxDistance;
  final List<ShotData> currentShots;
  final List<LevelData> completedLevels;
  final String currentPlayer;
  final List<String> players;
  final int currentPlayerIndex;
  final int incrementLevel;
  final int streak;
  final int maxStreak;

  int? get lastActualCarry {
    if (currentShots.isEmpty) return null;
    return currentShots.last.carryDistance.toInt();
  }

  bool get isLastShotWithinTarget {
    if (currentShots.isEmpty) return false;
    return currentShots.last.isSuccess;
  }


  GameInProgressState({
    required this.currentLevel,
    required this.totalLevels,
    required this.targetDistance,
    required this.toleranceWindow,
    required this.minDistance,
    required this.maxDistance,
    required this.currentShots,
    required this.completedLevels,
    required this.currentPlayer,
    required this.players,
    required this.currentPlayerIndex,
    required this.incrementLevel,
    required this.streak,
    required this.maxStreak,
  });

  GameInProgressState copyWith({
    int? currentLevel,
    int? totalLevels,
    int? targetDistance,
    int? toleranceWindow,
    int? minDistance,
    int? maxDistance,
    List<ShotData>? currentShots,
    List<LevelData>? completedLevels,
    String? currentPlayer,
    List<String>? players,
    int? currentPlayerIndex,
    int? incrementLevel,
    int? streak,
    int? maxStreak,
  }) {
    return GameInProgressState(
      currentLevel: currentLevel ?? this.currentLevel,
      totalLevels: totalLevels ?? this.totalLevels,
      targetDistance: targetDistance ?? this.targetDistance,
      toleranceWindow: toleranceWindow ?? this.toleranceWindow,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      currentShots: currentShots ?? this.currentShots,
      completedLevels: completedLevels ?? this.completedLevels,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      incrementLevel: incrementLevel ?? this.incrementLevel,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
    );
  }

  bool get allShotsSuccessful => currentShots.length == 3 && currentShots.every((shot) => shot.isSuccess);

  bool get hasFailedShots => currentShots.any((shot) => !shot.isSuccess);

  @override
  List<Object> get props => [
    currentLevel, totalLevels, targetDistance, toleranceWindow, minDistance, maxDistance,
    currentShots, completedLevels, currentPlayer, players, currentPlayerIndex
  ];
}

class SessionCompleteState extends LadderDrillState {
  final List<LevelData> allLevels;
  final int highestLevelReached;
  final double averageDistance;
  final int totalSuccessfulHits;
  final int totalAttempts;
  final int finalTargetDistance;
  final String longestStreak;
  final Map<String, PlayerStats> playerStats;

  SessionCompleteState({
    required this.allLevels,
    required this.highestLevelReached,
    required this.averageDistance,
    required this.totalSuccessfulHits,
    required this.totalAttempts,
    required this.longestStreak,
    required this.playerStats,
    required this.finalTargetDistance,
  });

  @override
  List<Object> get props => [allLevels, highestLevelReached, averageDistance, totalSuccessfulHits, totalAttempts, longestStreak, playerStats, finalTargetDistance];
}

class LevelCompleteState extends LadderDrillState {
  final int completedLevel;
  final int nextLevel;
  final int nextTargetDistance;
  final List<LevelData> completedLevels;
  final int streak;
  final int maxStreak;

  LevelCompleteState({
    required this.completedLevel,
    required this.nextLevel,
    required this.nextTargetDistance,
    required this.completedLevels,
    required this.streak,
    required this.maxStreak,
  });

  @override
  List<Object> get props => [
    completedLevel,
    nextLevel,
    nextTargetDistance,
    completedLevels,
    streak,
    maxStreak,
  ];
}
