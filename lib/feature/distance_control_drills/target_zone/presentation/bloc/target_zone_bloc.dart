import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/data/model/shot_result.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/data/model/target_zone_session.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_event.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_state.dart';
import 'package:onegolf/feature/golf_device/domain/entities/golf_data_entities.dart';

class TargetZoneBloc extends Bloc<TargetZoneEvent, TargetZoneState> {
  final BleManagementRepository bleRepository;
  StreamSubscription? _bleSubscription;
  Timer? _syncTimer;
  final StreamController<List<int>> _bleDataController =
      StreamController<List<int>>.broadcast();

  Stream<List<int>> get bleDataStream => _bleDataController.stream;
  static const int _defaultTargetDistance = 80;
  static const int _defaultDifficulty = 7;
  static const int _defaultShotCount = 3;
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
  GolfDataEntity? _firstPacketBaseline;
  GolfDataEntity? _lastValidGolfData;
  bool _isFirstPacketHandled = false;

  TargetZoneBloc({required this.bleRepository})
      : super(
          const TargetZoneSetupState(
            targetDistance: _defaultTargetDistance,
            difficulty: _defaultDifficulty,
            shotCount: _defaultShotCount,
          ),
        ) {
    on<TargetDistanceChanged>(_onTargetDistanceChanged);
    on<DifficultyChanged>(_onDifficultyChanged);
    on<ShotCountChanged>(_onShotCountChanged);
    on<StartGameEvent>(_onStartGame);
    on<ShotRecordedEvent>(_onShotRecorded);
    on<FinishSessionEvent>(_onFinishSession);
    on<RestartSessionEvent>(_onRestartSession);
    on<ResetGameEvent>(_onResetGame);
    on<BleDataReceivedEvent>(_onBleDataReceived);
  }


  bool _isSameGolfData(GolfDataEntity a, GolfDataEntity b) {
    return a.recordNumber == b.recordNumber &&
        a.clubName == b.clubName &&
        a.clubSpeed == b.clubSpeed &&
        a.ballSpeed == b.ballSpeed &&
        a.carryDistance == b.carryDistance &&
        a.totalDistance == b.totalDistance;
  }

  // Setup Phase Handlers
  Future<void> _onTargetDistanceChanged(
    TargetDistanceChanged event,
    Emitter<TargetZoneState> emit,
  ) async {
    if (state is TargetZoneSetupState) {
      final currentState = state as TargetZoneSetupState;
      final distance = event.distance.clamp(20, 350);
      emit(currentState.copyWith(targetDistance: distance));
    }
  }

  Future<void> _onDifficultyChanged(
    DifficultyChanged event,
    Emitter<TargetZoneState> emit,
  ) async {
    if (state is TargetZoneSetupState) {
      final currentState = state as TargetZoneSetupState;
      // Only accept 7, 5, or 3
      if ([7, 5, 3].contains(event.difficulty)) {
        emit(currentState.copyWith(difficulty: event.difficulty));
      }
    }
  }

  Future<void> _onShotCountChanged(
    ShotCountChanged event,
    Emitter<TargetZoneState> emit,
  ) async {
    if (state is TargetZoneSetupState) {
      final currentState = state as TargetZoneSetupState;
      // Validate: 1-10 or -1 for unlimited
      final shotCount = event.shotCount;
      if (shotCount == -1 || (shotCount >= 1 && shotCount <= 10)) {
        emit(currentState.copyWith(shotCount: shotCount));
      }
    }
  }

  // Game Phase Handlers
  Future<void> _onStartGame(
    StartGameEvent event,
    Emitter<TargetZoneState> emit,
  ) async {
    try {
      final session = TargetZoneSession(
        config: event.config,
        startTime: DateTime.now(),
        isActive: true,
      );

      emit(TargetZoneGameState(
        session: session,
        isWaitingForShot: true,
      ));
      _subscribeToBleData();
    } catch (e) {
      emit(TargetZoneErrorState('Failed to start game: $e'));
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

        // Small delay to ensure services ready
        await Future.delayed(Duration(milliseconds: 500));
      }
    } catch (e) {
      print('❌ Service discovery failed: $e');
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
    Emitter<TargetZoneState> emit,
  ) {
    print('🎮 Practice Games: Processing BLE data...');
    try {
      _parseGolfData(Uint8List.fromList(event.data));

      if (!_isFirstPacketHandled) {
        _isFirstPacketHandled = true;
        _firstPacketBaseline = _golfData;
        print("🧠 TargetZone: Baseline stored (first packet)");
        return;
      }

      // 🔁 SECOND PACKET vs BASELINE
      if (_firstPacketBaseline != null) {
        if (_isSameGolfData(_firstPacketBaseline!, _golfData)) {
          print("🔁 TargetZone: Same as baseline → ignored");
          return;
        }

        print("✅ TargetZone: Different from baseline → accepted");
        _firstPacketBaseline = null; // baseline consumed
      }

      // 🔁 DUPLICATE FILTER (after baseline phase)
      if (_lastValidGolfData != null &&
          _isSameGolfData(_lastValidGolfData!, _golfData)) {
        print("🔁 TargetZone: Duplicate packet ignored");
        return;
      }

      // ✅ VALID SHOT
      _lastValidGolfData = _golfData;


      add(
        ShotRecordedEvent(
          double.parse(
            _golfData.carryDistance.toStringAsFixed(1),
          ),
        ),
      );
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
    _syncTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (bleRepository.isConnected) {
        int checksum = (0x01 + 0x00) & 0xFF;
        await bleRepository.writeData([0x47, 0x46, 0x01, 0x00, 0x00, checksum]);
      }
    });
  }

  Future<void> _onShotRecorded(
    ShotRecordedEvent event,
    Emitter<TargetZoneState> emit,
  ) async {
    if (state is! TargetZoneGameState) return;

    final currentState = state as TargetZoneGameState;
    final session = currentState.session;

    final tolerance = session.config.tolerance ~/ 2;
    final targetDistance = session.config.targetDistance;
    final minRange = targetDistance - tolerance;
    final maxRange = targetDistance + tolerance;

    final isWithinTarget =
        event.actualCarry >= minRange && event.actualCarry <= maxRange;

    final shotResult = ShotResult(
      actualCarry: event.actualCarry,
      timestamp: DateTime.now(),
      isWithinTarget: isWithinTarget,
    );

    final updatedShots = [...session.shots, shotResult];
    final updatedSession = session.copyWith(
      shots: updatedShots,
      isActive: !session.isComplete ||
          updatedShots.length < session.config.totalShots,
    );

    emit(TargetZoneGameState(
      session: updatedSession,
      isWaitingForShot: true,
    ));

    await Future.delayed(Duration(milliseconds: 100));

    final isGameComplete = session.config.totalShots != -1 &&
        updatedShots.length >= session.config.totalShots;

    if (isGameComplete) {
      await Future.delayed(Duration(seconds: 1));
      emit(TargetZoneSessionCompleteState(updatedSession));
    }
  }

  Future<void> _onFinishSession(
    FinishSessionEvent event,
    Emitter<TargetZoneState> emit,
  ) async {
    if (state is! TargetZoneGameState) return;

    print('🛑 Stopping BLE subscription - Session finished');
    await _bleSubscription?.cancel();
    _syncTimer?.cancel();

    final currentState = state as TargetZoneGameState;
    final session = currentState.session.copyWith(
      endTime: DateTime.now(),
      isActive: false,
    );

    print('📄 Session complete - ${session.totalAttempts} total attempts');
    emit(TargetZoneSessionCompleteState(session));
  }

  Future<void> _onRestartSession(
    RestartSessionEvent event,
    Emitter<TargetZoneState> emit,
  ) async {
    if (state is TargetZoneSessionCompleteState) {

      print('🛑 Stopping old BLE subscription - Restarting session');
      await _bleSubscription?.cancel();
      _syncTimer?.cancel();
      _isFirstPacketHandled = false;
      _firstPacketBaseline = null;
      _lastValidGolfData = null;

      await Future.delayed(Duration(milliseconds: 500));

      final currentState = state as TargetZoneSessionCompleteState;
      final config = currentState.session.config;

      final newSession = TargetZoneSession(
        config: config,
        startTime: DateTime.now(),
        isActive: true,
      );

      emit(TargetZoneGameState(
        session: newSession,
        isWaitingForShot: true,
      ));
    }
  }

  Future<void> _onResetGame(
    ResetGameEvent event,
    Emitter<TargetZoneState> emit,
  ) async {
    // ✅ STOP ALL BLE RESOURCES
    print('🛑 Resetting game - Stopping all BLE resources');
    await _bleSubscription?.cancel();
    _syncTimer?.cancel();
    _isFirstPacketHandled = false;
    _firstPacketBaseline = null;
    _lastValidGolfData = null;

    emit(
      const TargetZoneSetupState(
        targetDistance: _defaultTargetDistance,
        difficulty: _defaultDifficulty,
        shotCount: _defaultShotCount,
      ),
    );
  }

  @override
  Future<void> close() {
    print('🛑 Closing TargetZoneBloc - Cleaning up all resources');
    _bleSubscription?.cancel();
    _syncTimer?.cancel();
    _bleDataController.close();
    return super.close();
  }

}
