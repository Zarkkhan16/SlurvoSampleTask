import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/level_data.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/player_stats.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/shot_data.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_event.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_state.dart';
import 'package:onegolf/feature/golf_device/domain/entities/golf_data_entities.dart';

class DistanceMasterBloc
    extends Bloc<DistanceMasterEvent, DistanceMasterState> {
  final BleManagementRepository bleRepository;
  StreamSubscription? _bleSubscription;
  Timer? _syncTimer;
  final StreamController<List<int>> _bleDataController =
      StreamController<List<int>>.broadcast();

  Stream<List<int>> get bleDataStream => _bleDataController.stream;
  GolfDataEntity _golfData = GolfDataEntity(
    battery: 0,
    recordNumber: 0,
    clubName: 0,
    clubSpeed: 0.0,
    ballSpeed: 0.0,
    carryDistance: 0.0,
    totalDistance: 0.0,
  );
  bool _units = false;
  int? _setupShortestDistance;
  int? _setupLongestDistance;
  int? _setupIncrementValue;

  DistanceMasterBloc({required this.bleRepository})
      : super(DistanceMasterInitial()) {
    on<InitializeGameEvent>(_onInitializeGame);
    on<StartGameEvent>(_onStartGame);
    on<ShotReceivedEvent>(_onShotReceived);
    on<RetryCurrentLevelEvent>(_onRetryCurrentLevel);
    on<EndSessionEvent>(_onEndSession);
    on<RestartGameEvent>(_onRestartGame);
    on<BleDataReceivedEvent>(_onBleDataReceived);
  }

  void _onInitializeGame(
      InitializeGameEvent event, Emitter<DistanceMasterState> emit) {
    // Validate inputs
    if (event.longestDistance <= event.shortestDistance) {
      emit(GameSetupState(
        shortestDistance: event.shortestDistance,
        longestDistance: event.longestDistance,
        difficulty: event.difficulty,
        increment: event.increment,
        customIncrement: event.customIncrement,
        players: event.players,
        errorMessage: 'Longest distance must be greater than shortest distance',
      ));
      return;
    }

    int incrementValue = event.increment;
    if (event.increment == 0 && event.customIncrement != null) {
      incrementValue = event.customIncrement!;
    }

    // Calculate levels
    int distance = event.longestDistance - event.shortestDistance;
    if (distance % incrementValue != 0) {
      emit(GameSetupState(
        shortestDistance: event.shortestDistance,
        longestDistance: event.longestDistance,
        difficulty: event.difficulty,
        increment: event.increment,
        customIncrement: event.customIncrement,
        players: event.players,
        errorMessage:
            'Distance range must be divisible by increment value. Levels cannot be in decimal points.',
      ));
      return;
    }

    int numberOfLevels = (distance / incrementValue).round() + 1;

    if (numberOfLevels < 2) {
      emit(GameSetupState(
        shortestDistance: event.shortestDistance,
        longestDistance: event.longestDistance,
        difficulty: event.difficulty,
        increment: event.increment,
        customIncrement: event.customIncrement,
        players: event.players,
        errorMessage:
            'At least 2 levels required. Increase distance range or reduce increment.',
      ));
      return;
    }

    // if (numberOfLevels > 20) {
    //   emit(GameSetupState(
    //     shortestDistance: event.shortestDistance,
    //     longestDistance: event.longestDistance,
    //     difficulty: event.difficulty,
    //     increment: event.increment,
    //     customIncrement: event.customIncrement,
    //     players: event.players,
    //     errorMessage:
    //         'Too many levels (${numberOfLevels}). '
    //             'Maximum 20 levels allowed.',
    //   ));
    //   return;
    // }

    // Store setup values for later use
    _setupShortestDistance = event.shortestDistance;
    _setupLongestDistance = event.longestDistance;
    _setupIncrementValue = incrementValue;

    // Success - ready to start
    emit(GameSetupState(
      shortestDistance: event.shortestDistance,
      longestDistance: event.longestDistance,
      difficulty: event.difficulty,
      increment: event.increment,
      customIncrement: event.customIncrement,
      players: event.players.isEmpty ? [event.players.first] : event.players,
      errorMessage: null,
    ));
  }

  void _onStartGame(StartGameEvent event, Emitter<DistanceMasterState> emit) {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;

      int incrementValue = _setupIncrementValue ?? setupState.increment;
      if (setupState.increment == 0 && setupState.customIncrement != null) {
        incrementValue = setupState.customIncrement!;
      }

      // difficulty is already an int (tolerance value: 3, 5, or 7)
      int tolerance = setupState.difficulty;

      // Calculate total levels
      int totalLevels =
          ((setupState.longestDistance - setupState.shortestDistance) /
                      incrementValue)
                  .round() +
              1;

      // Start with first level
      int firstTarget = setupState.shortestDistance;
      int minDistance = firstTarget - tolerance;
      int maxDistance = firstTarget + tolerance;

      emit(GameInProgressState(
        currentLevel: 1,
        totalLevels: totalLevels,
        targetDistance: firstTarget,
        toleranceWindow: tolerance,
        minDistance: minDistance,
        maxDistance: maxDistance,
        currentShots: [],
        completedLevels: [],
        currentPlayer: setupState.players.first,
        players: setupState.players,
        currentPlayerIndex: 0,
        incrementLevel: incrementValue,
      ));

      // Subscribe to BLE data
      _subscribeToBleData();
    }
  }

  Future<void> _onShotReceived(
      ShotReceivedEvent event, Emitter<DistanceMasterState> emit) async {
    if (state is GameInProgressState) {
      final currentState = state as GameInProgressState;

      final int carry = event.carryDistance.round();

      // Check if shot is within tolerance
      bool isSuccess = carry >= currentState.minDistance &&
          carry <= currentState.maxDistance;

      // Add shot
      final newShot = ShotData(
        carryDistance: event.carryDistance,
        isSuccess: isSuccess,
        timestamp: DateTime.now(),
      );

      List<ShotData> updatedShots = List.from(currentState.currentShots);
      List<ShotData> updatedSummary = List.from(currentState.summaryShots);

      // 🔥 Always save shot in summary list (fail + success)
      updatedSummary.add(newShot);

      if (updatedShots.length < 3) {
        updatedShots.add(newShot);
      }
      else {
        // summaryShots.add(updatedShots.first);
        updatedShots[0] = updatedShots[1];
        updatedShots[1] = updatedShots[2];
        updatedShots[2] = newShot;
      }

      emit(currentState.copyWith(currentShots: updatedShots,  summaryShots: updatedSummary,));

      if (updatedShots.length >= 3 &&
          updatedShots.every((shot) => shot.isSuccess)) {
        await Future.delayed(const Duration(milliseconds: 500));
        final latestState = state as GameInProgressState;
        _moveToNextLevel(latestState, emit);
      }
    }
  }

  void _onRetryCurrentLevel(
      RetryCurrentLevelEvent event, Emitter<DistanceMasterState> emit) {
    if (state is GameInProgressState) {
      final currentState = state as GameInProgressState;

      // Clear current shots and retry
      emit(currentState.copyWith(currentShots: []));
    }
  }

  void _moveToNextLevel(
      GameInProgressState currentState, Emitter<DistanceMasterState> emit) {
    // Save current level data
    final levelData = LevelData(
      level: currentState.currentLevel,
      targetDistance: currentState.targetDistance,
      minDistance: currentState.minDistance,
      maxDistance: currentState.maxDistance,
      shots: currentState.summaryShots,
      attempts: 1,
      // Track attempts if needed
      completed: true,
    );

    final updatedCompletedLevels = [...currentState.completedLevels, levelData];

    // Check if all levels complete
    if (currentState.currentLevel >= currentState.totalLevels) {
      // Game complete - calculate stats
      _calculateAndEmitSessionComplete(
          updatedCompletedLevels, currentState, emit);
      return;
    }

    // Move to next level
    int incrementValue = _setupIncrementValue ?? currentState.incrementLevel;

    int nextTarget = currentState.targetDistance + incrementValue;
    int minDistance = nextTarget - currentState.toleranceWindow;
    int maxDistance = nextTarget + currentState.toleranceWindow;

    emit(GameInProgressState(
      currentLevel: currentState.currentLevel + 1,
      totalLevels: currentState.totalLevels,
      targetDistance: nextTarget,
      toleranceWindow: currentState.toleranceWindow,
      minDistance: minDistance,
      maxDistance: maxDistance,
      currentShots: [],
      summaryShots: [],
      completedLevels: updatedCompletedLevels,
      currentPlayer: currentState.currentPlayer,
      players: currentState.players,
      currentPlayerIndex: currentState.currentPlayerIndex,
      incrementLevel: incrementValue,
    ));
  }

  void _calculateAndEmitSessionComplete(
    List<LevelData> allLevels,
    GameInProgressState currentState,
    Emitter<DistanceMasterState> emit,
  ) {
    // Calculate statistics
    int totalSuccessful = 0;
    int totalAttempts = 0;
    double totalDistance = 0;
    int shotCount = 0;

    for (var level in allLevels) {
      for (var shot in level.shots) {
        if (shot.isSuccess) {
          totalSuccessful++;
          totalDistance += shot.carryDistance;
          shotCount++;
        }
        totalAttempts++;
      }
    }

    double averageDistance = shotCount > 0 ? totalDistance / shotCount : 0;

    // Calculate longest streak
    int currentStreak = 0;
    int longestStreak = 0;

    for (var level in allLevels) {
      for (var shot in level.shots) {
        if (shot.isSuccess) {
          currentStreak++;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else {
          currentStreak = 0;
        }
      }
    }

    emit(SessionCompleteState(
      allLevels: allLevels,
      highestLevelReached: allLevels.length,
      averageDistance: averageDistance,
      totalSuccessfulHits: totalSuccessful,
      totalAttempts: totalAttempts,
      longestStreak: '$longestStreak in a row',
      playerStats: {
        currentState.currentPlayer: PlayerStats(
          playerName: currentState.currentPlayer,
          levels: allLevels,
          highestLevel: allLevels.length,
          averageDistance: averageDistance,
        ),
      },
    ));
  }

  void _onEndSession(EndSessionEvent event, Emitter<DistanceMasterState> emit) {
    if (state is GameInProgressState) {
      final currentState = state as GameInProgressState;
      _calculateAndEmitSessionComplete(
          currentState.completedLevels, currentState, emit);
    }
  }

  void _onRestartGame(
      RestartGameEvent event, Emitter<DistanceMasterState> emit) {
    _bleSubscription?.cancel();
    _setupShortestDistance = null;
    _setupLongestDistance = null;
    _setupIncrementValue = null;
    emit(DistanceMasterInitial());
  }

  Future<void> _subscribeToBleData() async {
    print('🎮 Distance Master: Starting BLE listener...');

    if (!bleRepository.isConnected) {
      print('❌ Not connected');
      // if (state is GameInProgressState) {
      //   emit((state as GameInProgressState).copyWith(
      //     bleError: 'Device not connected',
      //   ));
      // }
      return;
    }

    try {
      final deviceId = bleRepository.connectedDeviceId;
      if (deviceId != null) {
        print('🔍 Re-discovering services...');
        await bleRepository.discoverServices(deviceId);
        print('✅ Services discovered');

        // Small delay to ensure services ready
        await Future.delayed(Duration(milliseconds: 500));
      }
    } catch (e) {
      print('❌ Service discovery failed: $e');
      // if (state is GameInProgressState) {
      //   emit((state as GameInProgressState).copyWith(
      //     bleError: 'Service discovery failed',
      //   ));
      // }
      return;
    }

    await _bleSubscription?.cancel();
    _bleSubscription = bleRepository.subscribeToNotifications().listen(
      (data) {
        print('📡 BLE Data received in Distance Master: $data');
        add(BleDataReceivedEvent(data));
        _bleDataController.add(data);
      },
      onError: (error) {
        print('❌ BLE error: $error');
        // if (state is GameInProgressState) {
        //   add(BleErrorEvent(error.toString()));
        // }
      },
      onDone: () {
        print('⚠️ Stream closed');
      },
    );
    _startSyncTimer();
    print('✅ Listener started');
  }

  void _onBleDataReceived(
    BleDataReceivedEvent event,
    Emitter<DistanceMasterState> emit,
  ) {
    print('🎮 Practice Games: Processing BLE data...');
    try {
      _parseGolfData(Uint8List.fromList(event.data));
      add(ShotReceivedEvent(_golfData.carryDistance));
    } catch (e) {
      print('❌ Failed to parse BLE data: $e');
    }
  }

  void _parseGolfData(Uint8List data) {
    if (data[0] != 0x47 || data[1] != 0x46) return;

    bool isMeters = (data[11] & 0x80) != 0;
    int carryHigh = data[11] & 0x7F;
    int carryLow = data[12];
    double carryDistance = ((carryHigh << 8) | carryLow) / 10.0;
    double totalDistance = ((data[13] << 8) | data[14]) / 10.0;

    if (isMeters) {
      carryDistance *= 1.09361;
      totalDistance *= 1.09361;
    }

    _golfData = GolfDataEntity(
      battery: data[3],
      recordNumber: (data[4] << 8) | data[5],
      clubName: data[6],
      clubSpeed: ((data[7] << 8) | data[8]) / 10.0,
      ballSpeed: ((data[9] << 8) | data[10]) / 10.0,
      carryDistance: carryDistance,
      totalDistance: totalDistance,
    );

    _units = isMeters ? false : true;

    print("📊 Parsed Golf Data:");
    print("   Record: ${_golfData.recordNumber}");
    print("   Club: ${_golfData.clubName}");
    print("   Carry: ${_golfData.carryDistance.toStringAsFixed(1)} YD");
    print("   Total: ${_golfData.totalDistance.toStringAsFixed(1)} YD");
    print("   Unit Mode: YARDS");
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(seconds: 2), (_) async {
      if (bleRepository.isConnected) {
        int checksum = (0x01 + 0x00) & 0xFF;
        await bleRepository.writeData([0x47, 0x46, 0x01, 0x00, 0x00, checksum]);
      }
    });
  }

  @override
  Future<void> close() {
    _bleSubscription?.cancel();
    return super.close();
  }
}
