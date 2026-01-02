import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/level_data.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/player_stats.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/data/models/shot_data.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_event.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_state.dart';
import 'package:onegolf/feature/golf_device/domain/entities/golf_data_entities.dart';

class LadderDrillBloc extends Bloc<LadderDrillEvent, LadderDrillState> {
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

  GolfDataEntity? _firstPacketBaseline;
  GolfDataEntity? _lastValidGolfData;
  bool _isFirstPacketHandled = false;
  LadderDrillBloc({required this.bleRepository}) : super(GameSetupState()) {
    // Setup Events
    on<UpdateShortestDistanceEvent>(_onUpdateShortestDistance);
    on<UpdateLongestDistanceEvent>(_onUpdateLongestDistance);
    on<UpdateDifficultyEvent>(_onUpdateDifficulty);
    on<UpdateIncrementEvent>(_onUpdateIncrement);
    on<UpdateCustomIncrementEvent>(_onUpdateCustomIncrement);
    on<AddPlayerEvent>(_onAddPlayer);
    on<RemovePlayerEvent>(_onRemovePlayer);
    on<EditPlayerEvent>(_onEditPlayer);

    // Game Events
    // on<InitializeGameEvent>(_onInitializeGame);
    on<StartGameEvent>(_onStartGame);
    on<ShotReceivedEvent>(_onShotReceived);
    on<NextLevelEvent>(_onNextLevel);
    on<BleDataReceivedEvent>(_onBleDataReceived);
    on<EndSessionEvent>(_onEndSession);
    on<RestartLadderDrillGameEvent>(_onRestartGame);

    _initializeBleListener();
  }

  void _initializeBleListener() {
    // _bleSubscription = bleRepository..listen((golfData) {
    //   if (state is GameInProgressState || state is LevelCompleteState) {
    //     // Process shot when we receive BLE data
    //     add(ShotReceivedEvent(golfData.carryDistance));
    //   }
    // });
  }

  // ========== Setup Screen Handlers ==========

  Future<void> _onUpdateShortestDistance(
    UpdateShortestDistanceEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;

      if (event.distance >= setupState.longestDistance) {
        return;
      }

      emit(setupState.copyWith(
        shortestDistance: event.distance,
        errorMessage: null,
      ));
    }
  }

  bool _isSameGolfData(GolfDataEntity a, GolfDataEntity b) {
    return a.recordNumber == b.recordNumber &&
        a.clubName == b.clubName &&
        a.clubSpeed == b.clubSpeed &&
        a.ballSpeed == b.ballSpeed &&
        a.carryDistance == b.carryDistance &&
        a.totalDistance == b.totalDistance;
  }

  Future<void> _onUpdateLongestDistance(
    UpdateLongestDistanceEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;

      if (event.distance <= setupState.shortestDistance) {
        return;
      }

      emit(setupState.copyWith(
        longestDistance: event.distance,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onUpdateDifficulty(
    UpdateDifficultyEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;
      emit(setupState.copyWith(difficulty: event.difficulty));
    }
  }

  Future<void> _onUpdateIncrement(
    UpdateIncrementEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;
      emit(
        setupState.copyWith(
          increment: event.increment,
          customIncrement: null,
        ),
      );
    }
  }

  Future<void> _onUpdateCustomIncrement(
    UpdateCustomIncrementEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;
      emit(
        setupState.copyWith(
          customIncrement: event.customIncrement,
        ),
      );
    }
  }

  Future<void> _onAddPlayer(
    AddPlayerEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;

      final updatedPlayers = List<String>.from(setupState.players)
        ..add(event.playerName);

      emit(setupState.copyWith(
        players: updatedPlayers,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onRemovePlayer(
    RemovePlayerEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;

      if (setupState.players.length <= 1) {
        emit(setupState.copyWith(
          errorMessage: 'At least one player is required',
        ));
        return;
      }

      final updatedPlayers = List<String>.from(setupState.players)
        ..removeAt(event.playerIndex);

      emit(setupState.copyWith(
        players: updatedPlayers,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onEditPlayer(
    EditPlayerEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;
      if (setupState.players
          .where((p) => p != setupState.players[event.playerIndex])
          .contains(event.newName)) {
        emit(setupState.copyWith(
          errorMessage: 'Player with this name already exists',
        ));
        return;
      }

      final updatedPlayers = List<String>.from(setupState.players);
      updatedPlayers[event.playerIndex] = event.newName;

      emit(setupState.copyWith(
        players: updatedPlayers,
        errorMessage: null,
      ));
    }
  }

  // ========== Game Progress Handlers ==========

  // Future<void> _onInitializeGame(
  //   InitializeGameEvent event,
  //   Emitter<LadderDrillState> emit,
  // ) async {
  //   // Calculate game parameters
  //   final totalDistance = event.longestDistance - event.shortestDistance;
  //   final incrementValue = event.customIncrement ?? event.increment;
  //   final totalLevels = (totalDistance ~/ incrementValue) + 1;
  //
  //   // Initialize first level
  //   final firstLevelDistance = event.shortestDistance;
  //   final toleranceWindow = event.difficulty;
  //
  //   emit(GameInProgressState(
  //     currentLevel: 1,
  //     totalLevels: totalLevels,
  //     targetDistance: firstLevelDistance,
  //     toleranceWindow: toleranceWindow,
  //     minDistance: firstLevelDistance - toleranceWindow,
  //     maxDistance: firstLevelDistance + toleranceWindow,
  //     currentShots: [],
  //     completedLevels: [],
  //     currentPlayer: event.players[0],
  //     players: event.players,
  //     currentPlayerIndex: 0,
  //     incrementLevel: incrementValue,
  //   ));
  // }

  Future<void> _onStartGame(
    StartGameEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameSetupState) {
      final setupState = state as GameSetupState;

      // Calculate levels
      final incrementValue = setupState.increment == 0
          ? (setupState.customIncrement ?? 5)
          : setupState.increment;

      final totalDistance =
          setupState.longestDistance - setupState.shortestDistance;
      final totalLevels = (totalDistance ~/ incrementValue) + 1;

      emit(GameInProgressState(
        currentLevel: 1,
        totalLevels: totalLevels,
        targetDistance: setupState.shortestDistance,
        toleranceWindow: setupState.difficulty,
        minDistance: setupState.shortestDistance - setupState.difficulty,
        maxDistance: setupState.shortestDistance + setupState.difficulty,
        currentShots: [],
        completedLevels: [],
        currentPlayer: setupState.players[0],
        players: setupState.players,
        currentPlayerIndex: 0,
        incrementLevel: incrementValue,
        streak: 0,
        maxStreak: 0,
      ));

      _subscribeToBleData();
    }
  }

  Future<void> _subscribeToBleData() async {
    print('🎮 Distance Master: Starting BLE listener...');

    if (!bleRepository.isConnected) {
      print('❌ Not connected');
      return;
    }

    try {
      final deviceId = bleRepository.connectedDeviceId;
      if (deviceId != null) {
        print('🔍 Re-discovering services...');
        await bleRepository.discoverServices(deviceId);
        print('✅ Services discovered');
        await Future.delayed(Duration(milliseconds: 500));
      }
    } catch (e) {
      print('❌ Service discovery failed: $e');
      return;
    }

    await _bleSubscription?.cancel();
    _bleSubscription = bleRepository.subscribeToNotifications().listen(
      (data) {
        // print('📡 BLE Data received in Distance Master: $data');
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
    Emitter<LadderDrillState> emit,
  ) {
    // print('🎮 Practice Games: Processing BLE data...');
    try {
      _parseGolfData(Uint8List.fromList(event.data));

      // 🧠 FIRST PACKET → baseline (ZERO or NON-ZERO)
      if (!_isFirstPacketHandled) {
        _isFirstPacketHandled = true;
        _firstPacketBaseline = _golfData;
        print("🧠 LadderDrill: Baseline stored (first packet)");
        return;
      }

      // 🔁 Compare with baseline ONCE
      if (_firstPacketBaseline != null) {
        if (_isSameGolfData(_firstPacketBaseline!, _golfData)) {
          print("🔁 LadderDrill: Same as baseline → ignored");
          return;
        }

        print("✅ LadderDrill: Different from baseline → accepted");
        _firstPacketBaseline = null; // consume baseline
      }

      // 🔁 Duplicate protection (after baseline)
      if (_lastValidGolfData != null &&
          _isSameGolfData(_lastValidGolfData!, _golfData)) {
        print("🔁 LadderDrill: Duplicate ignored");
        return;
      }

      // ✅ VALID SHOT
      _lastValidGolfData = _golfData;


      add(ShotReceivedEvent(_golfData.carryDistance));
    } catch (e) {
      // print('❌ Failed to parse BLE data: $e');
    }
  }


  void _resetBaselineLogic() {
    _isFirstPacketHandled = false;
    _firstPacketBaseline = null;
    _lastValidGolfData = null;
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

    // _units = isMeters ? false : true;

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

  Future<void> _onShotReceived(
    ShotReceivedEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is GameInProgressState) {
      final gameState = state as GameInProgressState;

      final double carry = event.carryDistance;

      final isSuccess = carry >= gameState.minDistance &&
          carry <= gameState.maxDistance;

      final newShot = ShotData(
        timestamp: DateTime.now(),
        isSuccess: isSuccess,
        carryDistance: event.carryDistance,
      );

      List<ShotData> updatedShots = List.from(gameState.currentShots);
      List<ShotData> updatedSummary = List.from(gameState.summaryShots);

      updatedSummary.add(newShot);

      int newStreak = gameState.streak;
      int newMaxStreak = gameState.maxStreak;

      updatedShots.add(newShot);

      if (isSuccess) {
        newStreak++;
        if (newStreak > newMaxStreak) {
          newMaxStreak = newStreak;
        }

        emit(gameState.copyWith(
          currentShots: updatedShots,
          streak: newStreak,
          maxStreak: newMaxStreak,
        ));

        // WAIT 2 seconds to let user see the successful shot
        await Future.delayed(Duration(seconds: 2));

        // Create level data
        final levelData = LevelData(
          level: gameState.currentLevel,
          targetDistance: gameState.targetDistance,
          shots: updatedShots,
          completed: true,
          attempts: updatedShots.length,
          maxDistance: gameState.maxDistance,
          minDistance: gameState.minDistance,
        );

        final updatedLevels = List<LevelData>.from(gameState.completedLevels)
          ..add(levelData);

        // Check if game is complete
        if (gameState.currentLevel >= gameState.totalLevels) {
          // Game complete
          _emitSessionComplete(emit, gameState, updatedLevels, newMaxStreak);
        } else {
          // Show success state, then move to next level
          final nextTargetDistance =
              gameState.targetDistance + gameState.incrementLevel;
          // await Future.delayed(Duration(seconds: 10));
          emit(LevelCompleteState(
            completedLevel: gameState.currentLevel,
            nextLevel: gameState.currentLevel + 1,
            nextTargetDistance: nextTargetDistance,
            completedLevels: updatedLevels,
            streak: newStreak,
            maxStreak: newMaxStreak,
            // Pass these for NextLevelEvent
            totalLevels: gameState.totalLevels,
            toleranceWindow: gameState.toleranceWindow,
            currentPlayer: gameState.currentPlayer,
            players: gameState.players,
            incrementLevel: gameState.incrementLevel,
          ));
        }
      } else {

        newStreak = 0;

        emit(gameState.copyWith(
          currentShots: updatedShots,
          streak: newStreak,
        ));

        //
        // // Max attempts reached, still move to next level
        // final levelData = LevelData(
        //   level: gameState.currentLevel,
        //   targetDistance: gameState.targetDistance,
        //   shots: updatedShots,
        //   completed: false,
        //   attempts: updatedShots.length,
        //   maxDistance: gameState.maxDistance,
        //   minDistance: gameState.minDistance,
        // );
        //
        // final updatedLevels = List<LevelData>.from(gameState.completedLevels)
        //   ..add(levelData);
        //
        // if (gameState.currentLevel >= gameState.totalLevels) {
        //   _emitSessionComplete(emit, gameState, updatedLevels, newMaxStreak);
        // } else {
        //   final nextTargetDistance =
        //       gameState.targetDistance + gameState.incrementLevel;
        //
        //   emit(LevelCompleteState(
        //     completedLevel: gameState.currentLevel,
        //     nextLevel: gameState.currentLevel + 1,
        //     nextTargetDistance: nextTargetDistance,
        //     completedLevels: updatedLevels,
        //     streak: newStreak,
        //     maxStreak: newMaxStreak,
        //   ));
        // }
      }
    }
  }

  Future<void> _onNextLevel(
    NextLevelEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    if (state is LevelCompleteState) {
      final levelState = state as LevelCompleteState;

      // emit(GameInProgressState(
      //   currentLevel: levelState.nextLevel,
      //   totalLevels:
      //       levelState.nextLevel + ((80 - levelState.nextTargetDistance) ~/ 5),
      //   // Adjust based on your logic
      //   targetDistance: levelState.nextTargetDistance,
      //   toleranceWindow: 7,
      //   // Get from previous state
      //   minDistance: levelState.nextTargetDistance - 7,
      //   maxDistance: levelState.nextTargetDistance + 7,
      //   currentShots: [],
      //   completedLevels: levelState.completedLevels,
      //   currentPlayer: "Player",
      //   players: ["Player"],
      //   currentPlayerIndex: 0,
      //   incrementLevel: 5,
      //   streak: levelState.streak,
      //   maxStreak: levelState.maxStreak,
      // ));

      emit(GameInProgressState(
        currentLevel: levelState.nextLevel,
        totalLevels: levelState.totalLevels, // Use existing value
        targetDistance: levelState.nextTargetDistance,
        toleranceWindow: levelState.toleranceWindow,
        minDistance: levelState.nextTargetDistance - levelState.toleranceWindow,
        maxDistance: levelState.nextTargetDistance + levelState.toleranceWindow,
        currentShots: [],
        completedLevels: levelState.completedLevels,
        currentPlayer: levelState.currentPlayer,
        players: levelState.players,
        currentPlayerIndex: 0,
        incrementLevel: levelState.incrementLevel,
        streak: levelState.streak,
        maxStreak: levelState.maxStreak,
      ));

    }
  }

  Future<void> _onEndSession(
    EndSessionEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    _resetBaselineLogic();
    if (state is GameInProgressState) {
      final gameState = state as GameInProgressState;
      _emitSessionComplete(
          emit, gameState, gameState.completedLevels, gameState.maxStreak);
    }
  }

  Future<void> _onRestartGame(
      RestartLadderDrillGameEvent event,
    Emitter<LadderDrillState> emit,
  ) async {
    _stopBle();
    _resetBaselineLogic();
    // emit(GameSetupState());
  }

  // ========== Helper Methods ==========

  void _emitSessionComplete(
    Emitter<LadderDrillState> emit,
    GameInProgressState gameState,
    List<LevelData> allLevels,
    int maxStreak,
  ) {
    // Calculate statistics
    final totalAttempts = allLevels.fold<int>(
      0,
      (sum, level) => sum + level.attempts,
    );

    final totalSuccessful = allLevels.where((level) => level.completed).length;

    final averageDistance = allLevels.isEmpty
        ? 0.0
        : allLevels.fold<double>(
              0,
              (sum, level) =>
                  sum +
                  level.shots.fold(0.0, (s, shot) => s + shot.carryDistance),
            ) /
            allLevels.fold<int>(0, (sum, level) => sum + level.shots.length);

    _stopBle();
    emit(SessionCompleteState(
      allLevels: allLevels,
      highestLevelReached: gameState.currentLevel,
      averageDistance: averageDistance,
      totalSuccessfulHits: totalSuccessful,
      totalAttempts: totalAttempts,
      longestStreak: maxStreak > 1 ? '$maxStreak in a row' : 'None',
      playerStats: {},
      // Calculate if needed
      finalTargetDistance: gameState.targetDistance,
    ));
  }
  Future<void> _stopBle() async {
    print("🛑 LadderDrill: Stopping BLE");

    await _bleSubscription?.cancel();
    _bleSubscription = null;

    _syncTimer?.cancel();
    _syncTimer = null;

    _resetBaselineLogic();
  }


  @override
  Future<void> close() {
    _bleSubscription?.cancel();
    _resetBaselineLogic();
    return super.close();
  }
}
