import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/golf_device/domain/entities/golf_data_entities.dart';

import '../../../ble_management/domain/repositories/ble_management_repository.dart';
import '../../domain/entities/club_entity.dart';
import '../../domain/entities/club_gapping_session_entity.dart';
import '../../domain/entities/club_summary_entity.dart';
import '../../domain/entities/shot_entity.dart';
import 'club_gapping_event.dart';
import 'club_gapping_state.dart';

class ClubGappingBloc extends Bloc<ClubGappingEvent, ClubGappingState> {
  final BleManagementRepository bleRepository;
  StreamSubscription? _bleSubscription;
  Timer? _syncTimer;
  int _currentClubId = 0;
  GolfDataEntity? _firstPacketBaseline;
  GolfDataEntity? _lastValidGolfData;
  bool _isFirstPacketHandled = false;
  bool _clubCommandSent = false;

  ClubGappingBloc({required this.bleRepository}) : super(ClubGappingInitial()) {
    on<LoadAvailableClubsEvent>(_onLoadAvailableClubs);
    on<ToggleClubSelectionEvent>(_onToggleClubSelection);
    on<UpdateShotsPerClubEvent>(_onUpdateShotsPerClub);
    on<StartGappingSessionEvent>(_onStartGappingSession);
    on<ShotDataReceivedEvent>(_onShotDataReceived);
    on<RecordShotEvent>(_onRecordShot);
    on<ReHitShotEvent>(_onReHitShot);
    on<DeleteLastShotEvent>(_onDeleteLastShot);
    on<CompleteCurrentClubEvent>(_onCompleteCurrentClub);
    on<RetakeCurrentClubEvent>(_onRetakeCurrentClub);
    on<MoveToNextClubEvent>(_onMoveToNextClub);
    on<GoToClubEvent>(_onGoToClub);
    on<CompleteSessionEvent>(_onCompleteSession);
    on<RetakeSessionEvent>(_onRetakeSession);
    on<SaveSessionEvent>(_onSaveSession);
    on<ExitSessionEvent>(_onExitSession);
    on<ResetToSelectionEvent>(_onResetToSelection);
    on<SelectCustomShotsEvent>(_onSelectCustomShots);
    on<StopListeningToBleDataClubEvent>(_onStopListeningToBleData);
  }

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    _bleSubscription?.cancel();
    return super.close();
  }

  // ============================================================
  // BLE SUBSCRIPTION & SYNC
  // ============================================================

  Future<void> _subscribeToBleShotData() async {
    if (!bleRepository.isConnected) {
      print('❌ Not connected to device');
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

    // Cancel previous subscription
    await _bleSubscription?.cancel();

    // Subscribe to BLE notifications
    _bleSubscription = bleRepository.subscribeToNotifications().listen(
      (data) {
        print('📡 BLE Data received: $data');
        _parseGolfData(Uint8List.fromList(data));
      },
      onError: (error) {
        print('❌ BLE error: $error');
      },
      onDone: () {
        print('⚠️ BLE stream closed');
      },
    );

    // Start sync timer (every 1 second)
    _startSyncTimer();

    print('✅ BLE subscription started with sync timer');
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();

    // ✅ Send sync packet every 1 second with current club ID
    _syncTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (bleRepository.isConnected) {
        await _sendSyncPacket();
      }
    });

    print('⏱️ Sync timer started (1 second interval)');
  }

  Future<void> _sendClubCommand(int clubId) async {
    print("🎯 Sending CLUB command for clubId: $clubId");

    int checksum = (0x02 + clubId) & 0xFF;

    final packet = [
      0x47,
      0x46,
      0x02, // 👈 CLUB COMMAND
      clubId,
      0x00,
      checksum,
    ];

    await bleRepository.writeData(packet);
  }

  Future<void> _sendSyncPacket() async {
    int checksum = (0x01 + _currentClubId) & 0xFF;
    final packet = [0x47, 0x46, 0x01, _currentClubId, 0x00, checksum];
    await bleRepository.writeData(packet);
  }

  bool _isSameGolfData(GolfDataEntity a, GolfDataEntity b) {
    return a.recordNumber == b.recordNumber &&
        a.clubName == b.clubName &&
        a.clubSpeed == b.clubSpeed &&
        a.ballSpeed == b.ballSpeed &&
        a.carryDistance == b.carryDistance &&
        a.totalDistance == b.totalDistance;
  }

  void _parseGolfData(Uint8List data) {
    // Validate packet header
    if (data.length < 15 || data[0] != 0x47 || data[1] != 0x46) {
      print('⚠️ Invalid packet header');
      return;
    }

    // Parse data
    bool isMeters = (data[11] & 0x80) != 0;
    int carryHigh = data[11] & 0x7F;
    int carryLow = data[12];
    double carryDistance = ((carryHigh << 8) | carryLow) / 10.0;
    double totalDistance = ((data[13] << 8) | data[14]) / 10.0;
    double clubSpeed = ((data[7] << 8) | data[8]) / 10.0;
    double ballSpeed = ((data[9] << 8) | data[10]) / 10.0;

    // Convert to yards if in meters
    if (isMeters) {
      carryDistance *= 1.09361;
      totalDistance *= 1.09361;
    }

    // Calculate smash factor
    double smashFactor = clubSpeed > 0 ? ballSpeed / clubSpeed : 0.0;

    print("📊 Parsed Golf Data:");
    print("   Club Speed: ${clubSpeed.toStringAsFixed(1)} mph");
    print("   Ball Speed: ${ballSpeed.toStringAsFixed(1)} mph");
    print("   Carry: ${carryDistance.toStringAsFixed(1)} yds");
    print("   Total: ${totalDistance.toStringAsFixed(1)} yds");
    print("   Smash: ${smashFactor.toStringAsFixed(2)}");

    final _golfData = GolfDataEntity(
      battery: data[3],
      recordNumber: (data[4] << 8) | data[5],
      clubName: data[6],
      clubSpeed: clubSpeed,
      ballSpeed: ballSpeed,
      carryDistance: carryDistance,
      totalDistance: totalDistance,
    );

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

    // ✅ Trigger shot received event
    add(ShotDataReceivedEvent(
      carryDistance: _golfData.carryDistance,
      totalDistance: _golfData.totalDistance,
      clubSpeed: _golfData.clubSpeed,
      ballSpeed: _golfData.ballSpeed,
      smashFactor: _golfData.smashFactor,
    ));
  }

  void _stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _isFirstPacketHandled = false;
    _firstPacketBaseline = null;
    _lastValidGolfData = null;
    // _clubCommandSent = false;
    print('⏹️ Sync timer stopped');
  }

  // ============================================================
  // LOAD AVAILABLE CLUBS
  // ============================================================

  Future<void> _onLoadAvailableClubs(
    LoadAvailableClubsEvent event,
    Emitter<ClubGappingState> emit,
  ) async {
    emit(ClubGappingLoading());

    try {
      final clubs = _getPredefinedClubs();

      emit(ClubSelectionState(
        availableClubs: clubs,
        selectedClubs: [],
        shotsPerClub: 3,
        canStartSession: false,
      ));
    } catch (e) {
      emit(ClubGappingError(
        message: 'Failed to load clubs: $e',
      ));
    }
  }

  // ============================================================
  // TOGGLE CLUB SELECTION
  // ============================================================

  void _onToggleClubSelection(
    ToggleClubSelectionEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! ClubSelectionState) return;

    final currentState = state as ClubSelectionState;

    // Update club selection
    final updatedClubs = currentState.availableClubs.map((club) {
      if (club.id == event.clubId) {
        return club.copyWith(isSelected: !club.isSelected);
      }
      return club;
    }).toList();

    final selectedClubs = updatedClubs.where((c) => c.isSelected).toList();

    emit(currentState.copyWith(
      availableClubs: updatedClubs,
      selectedClubs: selectedClubs,
      canStartSession: selectedClubs.length >= 2,
    ));
  }

  // ============================================================
  // UPDATE SHOTS PER CLUB
  // ============================================================

  void _onUpdateShotsPerClub(
    UpdateShotsPerClubEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! ClubSelectionState) return;

    final currentState = state as ClubSelectionState;

    // ✅ CRITICAL: Check if preset button (3, 5, 7)
    final isPresetButton = [3, 5, 7].contains(event.shotsPerClub);

    print('📝 Shot update: ${event.shotsPerClub}');
    print('   Preset: $isPresetButton');
    print('   Custom: ${!isPresetButton}');

    emit(currentState.copyWith(
      shotsPerClub: event.shotsPerClub,
      isCustomSelected: !isPresetButton,
    ));
  }

  void _onSelectCustomShots(
    SelectCustomShotsEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! ClubSelectionState) return;

    final currentState = state as ClubSelectionState;

    emit(currentState.copyWith(
      isCustomSelected: true,
      shotsPerClub: currentState.shotsPerClub, // Keep current value
    ));
  }

  // ============================================================
  // START GAPPING SESSION
  // ============================================================

  void _onStartGappingSession(
    StartGappingSessionEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (event.selectedClubs.length < 2) {
      emit(ClubGappingError(
        message: 'Please select at least 2 clubs',
        previousState: state,
      ));
      return;
    }

    final reversedClubs = List<ClubEntity>.from(event.selectedClubs.reversed);

    // Create new session
    final session = ClubGappingSessionEntity(
      id: "",
      selectedClubs: reversedClubs,
      shotsPerClub: event.shotsPerClub,
      currentClubIndex: 0,
      clubShots: {},
      startTime: DateTime.now(),
      status: SessionStatus.active,
    );

    // Start recording for first club
    final firstClub = session.selectedClubs[0];

    // ✅ Set current club ID for sync packets
    _currentClubId = firstClub.clubId;
    _clubCommandSent = false;

    emit(RecordingShotsState(
      session: session,
      currentClub: firstClub,
      currentClubShots: [],
      currentShotNumber: 0,
      totalShots: session.shotsPerClub,
      isWaitingForShot: true,
    ));

    _sendClubCommand(_currentClubId).then((_) {
      _clubCommandSent = true;

      // 2️⃣ Reset baseline for new club
      _isFirstPacketHandled = false;
      _firstPacketBaseline = null;
      _lastValidGolfData = null;

      // 3️⃣ Start BLE listening + sync
      _subscribeToBleShotData();
    });

    // Subscribe to BLE and start sync
    // _subscribeToBleShotData();

    print(
        '🏌️ Started session for club: ${firstClub.name} (ID: $_currentClubId)');
  }

  // ============================================================
  // SHOT DATA RECEIVED (from BLE)
  // ============================================================

  Future<void> _onShotDataReceived(
    ShotDataReceivedEvent event,
    Emitter<ClubGappingState> emit,
  ) async {
    if (state is! RecordingShotsState) return;

    final currentState = state as RecordingShotsState;

    // Create shot entity
    final shot = ShotEntity(
      id: "",
      clubId: currentState.currentClub.id,
      shotNumber: currentState.currentClubShots.length + 1,
      carryDistance: event.carryDistance,
      totalDistance: event.totalDistance,
      clubSpeed: event.clubSpeed,
      ballSpeed: event.ballSpeed,
      smashFactor: event.smashFactor,
      timestamp: DateTime.now(),
      starRating: 3,
    );

    // Update state with new shot
    final updatedShots = [...currentState.currentClubShots, shot];
    final updatedSession = currentState.session.copyWith(
      clubShots: {
        ...currentState.session.clubShots,
        currentState.currentClub.id: updatedShots,
      },
    );

    emit(currentState.copyWith(
      session: updatedSession,
      currentClubShots: updatedShots,
      currentShotNumber: updatedShots.length,
      latestShot: shot,
      isWaitingForShot: false,
    ));

    print(
        '✅ Shot ${updatedShots.length} recorded for ${currentState.currentClub.name}');

    // Auto-complete club if all shots recorded
    if (updatedShots.length >= currentState.totalShots) {
      print('⏰ Last shot recorded! Waiting 1 second before showing summary...');
      await Future.delayed(
        Duration(seconds: 1),
      );
      add(CompleteCurrentClubEvent());
    }
  }

  // ============================================================
  // RECORD SHOT MANUALLY
  // ============================================================

  void _onRecordShot(
    RecordShotEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! RecordingShotsState) return;

    final currentState = state as RecordingShotsState;

    final updatedShots = [...currentState.currentClubShots, event.shot];
    final updatedSession = currentState.session.copyWith(
      clubShots: {
        ...currentState.session.clubShots,
        currentState.currentClub.id: updatedShots,
      },
    );

    emit(currentState.copyWith(
      session: updatedSession,
      currentClubShots: updatedShots,
      currentShotNumber: updatedShots.length,
      latestShot: event.shot,
      isWaitingForShot: false,
    ));
  }

  // ============================================================
  // RE-HIT SHOT
  // ============================================================

  void _onReHitShot(
    ReHitShotEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! RecordingShotsState) return;

    final currentState = state as RecordingShotsState;

    if (currentState.currentClubShots.isEmpty) {
      print('⚠️ No shots to re-hit');
      return;
    }

    final updatedShots = List<ShotEntity>.from(currentState.currentClubShots)
      ..removeLast();

    // Update session with new shots list
    final updatedSession = currentState.session.copyWith(
      clubShots: {
        ...currentState.session.clubShots,
        currentState.currentClub.id: updatedShots,
      },
    );

    // ✅ FIX: Show previous shot if available, otherwise null (zeros)
    final ShotEntity? newLatestShot =
        updatedShots.isNotEmpty ? updatedShots.last : null;

    print('🔄 Re-hit: Removed shot, ${updatedShots.length} shots remaining');
    if (newLatestShot != null) {
      print(
          '   Showing previous shot data: ${newLatestShot.carryDistance.toStringAsFixed(1)} yds');
    } else {
      print('   No shots remaining - showing zeros');
    }

    emit(RecordingShotsState(
      session: updatedSession,
      currentClub: currentState.currentClub,
      currentClubShots: updatedShots,
      currentShotNumber: updatedShots.length,
      totalShots: currentState.totalShots,
      latestShot: newLatestShot,
      isWaitingForShot: true,
    ));
  }

  // ============================================================
  // DELETE LAST SHOT
  // ============================================================

  void _onDeleteLastShot(
    DeleteLastShotEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! RecordingShotsState) return;

    final currentState = state as RecordingShotsState;

    if (currentState.currentClubShots.isEmpty) return;

    final updatedShots = List<ShotEntity>.from(currentState.currentClubShots)
      ..removeLast();

    final updatedSession = currentState.session.copyWith(
      clubShots: {
        ...currentState.session.clubShots,
        currentState.currentClub.id: updatedShots,
      },
    );

    emit(currentState.copyWith(
      session: updatedSession,
      currentClubShots: updatedShots,
      currentShotNumber: updatedShots.length,
      latestShot: null,
      isWaitingForShot: true,
    ));
  }

  // ============================================================
  // COMPLETE CURRENT CLUB
  // ============================================================

  Future<void> _onCompleteCurrentClub(
    CompleteCurrentClubEvent event,
    Emitter<ClubGappingState> emit,
  ) async {
    if (state is! RecordingShotsState) return;

    final currentState = state as RecordingShotsState;

    // Create club summary
    final clubSummary = ClubSummaryEntity.fromShots(
      currentState.currentClub,
      currentState.currentClubShots,
    );

    // Check if there's a next club
    final nextIndex = currentState.session.currentClubIndex + 1;
    final hasNextClub = nextIndex < currentState.session.selectedClubs.length;

    ClubEntity? nextClub;
    if (hasNextClub) {
      nextClub = currentState.session.selectedClubs[nextIndex];
    }

    emit(ClubSummaryState(
      session: currentState.session,
      clubSummary: clubSummary,
      hasNextClub: hasNextClub,
      nextClub: nextClub,
    ));

    print('📊 Club summary for ${currentState.currentClub.name}');
  }

  // ============================================================
  // RETAKE CURRENT CLUB
  // ============================================================

  void _onRetakeCurrentClub(
    RetakeCurrentClubEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! ClubSummaryState) return;

    final currentState = state as ClubSummaryState;

    // Clear shots for current club
    final clubId = currentState.clubSummary.club.id;
    final updatedClubShots = Map<String, List<ShotEntity>>.from(
      currentState.session.clubShots,
    );
    updatedClubShots[clubId] = [];

    final updatedSession = currentState.session.copyWith(
      clubShots: updatedClubShots,
    );

    // ✅ Update current club ID for sync packets
    _currentClubId = currentState.clubSummary.club.clubId;

    _clubCommandSent = false;

    _syncTimer?.cancel();

    _isFirstPacketHandled = false;
    _firstPacketBaseline = null;
    _lastValidGolfData = null;

    _sendClubCommand(_currentClubId).then((_) {
      _clubCommandSent = true;
      _startSyncTimer();
    });

    // Return to recording state
    emit(RecordingShotsState(
      session: updatedSession,
      currentClub: currentState.clubSummary.club,
      currentClubShots: [],
      currentShotNumber: 0,
      totalShots: updatedSession.shotsPerClub,
      isWaitingForShot: true,
    ));

    print('🔄 Retaking club: ${currentState.clubSummary.club.name}');
  }

  // ============================================================
  // MOVE TO NEXT CLUB
  // ============================================================

  void _onMoveToNextClub(
    MoveToNextClubEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! ClubSummaryState) return;

    final currentState = state as ClubSummaryState;

    if (!currentState.hasNextClub) {
      // No more clubs, go to final summary
      _stopSyncTimer(); // ✅ Stop sync when session complete
      add(CompleteSessionEvent());
      return;
    }

    // Move to next club
    final nextIndex = currentState.session.currentClubIndex + 1;
    final nextClub = currentState.session.selectedClubs[nextIndex];

    final updatedSession = currentState.session.copyWith(
      currentClubIndex: nextIndex,
    );

    // ✅ Update current club ID for sync packets
    _currentClubId = nextClub.clubId;
    _clubCommandSent = false;

// 🛑 Stop sync before switching club
    _syncTimer?.cancel();

    _isFirstPacketHandled = false;
    _firstPacketBaseline = null;
    _lastValidGolfData = null;

    _sendClubCommand(_currentClubId).then((_) {
      _clubCommandSent = true;
      _startSyncTimer();
    });

    emit(RecordingShotsState(
      session: updatedSession,
      currentClub: nextClub,
      currentClubShots: updatedSession.clubShots[nextClub.id] ?? [],
      currentShotNumber: 0,
      totalShots: updatedSession.shotsPerClub,
      isWaitingForShot: true,
    ));

    print('➡️ Moved to next club: ${nextClub.name} (ID: $_currentClubId)');
  }

  // ============================================================
  // GO TO SPECIFIC CLUB
  // ============================================================

  void _onGoToClub(
    GoToClubEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    ClubGappingSessionEntity? session;

    if (state is RecordingShotsState) {
      session = (state as RecordingShotsState).session;
    } else if (state is ClubSummaryState) {
      session = (state as ClubSummaryState).session;
    } else if (state is SessionSummaryState) {
      session = (state as SessionSummaryState).session;
    }

    if (session == null || event.clubIndex >= session.selectedClubs.length) {
      return;
    }

    final targetClub = session.selectedClubs[event.clubIndex];
    final updatedSession = session.copyWith(currentClubIndex: event.clubIndex);

    // ✅ Update current club ID for sync packets
    _currentClubId = targetClub.clubId;

    emit(RecordingShotsState(
      session: updatedSession,
      currentClub: targetClub,
      currentClubShots: updatedSession.clubShots[targetClub.id] ?? [],
      currentShotNumber: 0,
      totalShots: updatedSession.shotsPerClub,
      isWaitingForShot: true,
    ));
  }

  // ============================================================
  // COMPLETE SESSION
  // ============================================================

  void _onCompleteSession(
    CompleteSessionEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    ClubGappingSessionEntity? session;

    if (state is RecordingShotsState) {
      session = (state as RecordingShotsState).session;
    } else if (state is ClubSummaryState) {
      session = (state as ClubSummaryState).session;
    }

    if (session == null) return;

    // ✅ Stop sync timer
    _stopSyncTimer();
    _bleSubscription?.cancel();
    _bleSubscription = null;
    print('🔌 BLE subscription cancelled');

    // Mark session as completed
    final completedSession = session.copyWith(
      status: SessionStatus.completed,
      endTime: DateTime.now(),
    );

    // Create summaries for all clubs
    final clubSummaries = <ClubSummaryEntity>[];
    final clubAverages = <String, double>{};

    for (final club in completedSession.selectedClubs) {
      final shots = completedSession.clubShots[club.id] ?? [];
      final summary = ClubSummaryEntity.fromShots(club, shots);
      clubSummaries.add(summary);
      clubAverages[club.id] = summary.averageCarryDistance;
    }

    emit(SessionSummaryState(
      session: completedSession,
      clubSummaries: clubSummaries,
      clubAverages: clubAverages,
    ));

    print('🏁 Session completed!');
  }

  // ============================================================
  // RETAKE SESSION
  // ============================================================

  void _onRetakeSession(
    RetakeSessionEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    if (state is! SessionSummaryState) return;

    final currentState = state as SessionSummaryState;

    // Reset session
    final resetSession = ClubGappingSessionEntity(
      id: "",
      selectedClubs: currentState.session.selectedClubs,
      shotsPerClub: currentState.session.shotsPerClub,
      currentClubIndex: 0,
      clubShots: {},
      startTime: DateTime.now(),
      status: SessionStatus.active,
    );

    // Start with first club
    final firstClub = resetSession.selectedClubs[0];

    // ✅ Update current club ID for sync packets
    _currentClubId = firstClub.clubId;

    emit(RecordingShotsState(
      session: resetSession,
      currentClub: firstClub,
      currentClubShots: [],
      currentShotNumber: 0,
      totalShots: resetSession.shotsPerClub,
      isWaitingForShot: true,
    ));

    _subscribeToBleShotData();

    print('🔄 Session restarted');
  }

  // ============================================================
  // SAVE SESSION
  // ============================================================

  Future<void> _onSaveSession(
    SaveSessionEvent event,
    Emitter<ClubGappingState> emit,
  ) async {
    ClubGappingSessionEntity? session;

    if (state is SessionSummaryState) {
      session = (state as SessionSummaryState).session;
    } else if (state is RecordingShotsState) {
      session = (state as RecordingShotsState).session;
    } else if (state is ClubSummaryState) {
      session = (state as ClubSummaryState).session;
    }

    if (session == null) return;

    emit(SavingSessionState(session));

    try {
      // TODO: Save to Firestore
      await Future.delayed(Duration(seconds: 1));

      emit(SessionSavedState(session.id));

      // Return to previous state
      if (state is SessionSummaryState) {
        final summaryState = state as SessionSummaryState;
        emit(summaryState);
      }
    } catch (e) {
      emit(ClubGappingError(
        message: 'Failed to save session: $e',
        previousState: state,
      ));
    }
  }

  // ============================================================
  // EXIT SESSION
  // ============================================================

  Future<void> _onStopListeningToBleData(
    StopListeningToBleDataClubEvent event,
    Emitter<ClubGappingState> emit,
  ) async {
    await _bleSubscription?.cancel();
    _bleSubscription = null;

    _isFirstPacketHandled = false;
    _firstPacketBaseline = null;
    _lastValidGolfData = null;

    _syncTimer?.cancel();
    _syncTimer = null;
    _clubCommandSent = false;

    print('✅ BLE listener stopped');
  }

  void _onExitSession(
    ExitSessionEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    // ✅ Stop sync timer
    _stopSyncTimer();

    // Go back to initial state
    emit(ClubGappingInitial());
  }

  // ============================================================
  // RESET TO SELECTION
  // ============================================================

  void _onResetToSelection(
    ResetToSelectionEvent event,
    Emitter<ClubGappingState> emit,
  ) {
    // ✅ Stop sync timer
    _stopSyncTimer();

    // Load clubs again
    add(LoadAvailableClubsEvent());
  }

  // ============================================================
  // PREDEFINED CLUBS DATA (with numeric IDs)
  // ============================================================

  List<ClubEntity> _getPredefinedClubs() {
    return [
      // WOODS (IDs: 0-3)
      ClubEntity(
        id: 'driver',
        name: 'Driver',
        category: ClubCategory.woods,
        clubId: 0,
      ),
      ClubEntity(
        id: '2w',
        name: '2 Wood',
        category: ClubCategory.woods,
        clubId: 1,
      ),
      ClubEntity(
        id: '3w',
        name: '3 Wood',
        category: ClubCategory.woods,
        clubId: 2,
      ),
      ClubEntity(
        id: '5w',
        name: '5 Wood',
        category: ClubCategory.woods,
        clubId: 3,
      ),
      ClubEntity(
        id: '7w',
        name: '7 Wood',
        category: ClubCategory.woods,
        clubId: 4,
      ),

      // HYBRIDS (IDs: 4-8)
      ClubEntity(
        id: '1h',
        name: '1 Hybrid',
        category: ClubCategory.hybrids,
        clubId: 5,
      ),
      ClubEntity(
        id: '2h',
        name: '2 Hybrid',
        category: ClubCategory.hybrids,
        clubId: 6,
      ),
      ClubEntity(
        id: '3h',
        name: '3 Hybrid',
        category: ClubCategory.hybrids,
        clubId: 7,
      ),
      ClubEntity(
        id: '4h',
        name: '4 Hybrid',
        category: ClubCategory.hybrids,
        clubId: 8,
      ),
      ClubEntity(
        id: '5h',
        name: '5 Hybrid',
        category: ClubCategory.hybrids,
        clubId: 9,
      ),

      // IRONS (IDs: 9-16)
      ClubEntity(
        id: '2i',
        name: '2 Iron',
        category: ClubCategory.irons,
        clubId: 10,
      ),
      ClubEntity(
        id: '3i',
        name: '3 Iron',
        category: ClubCategory.irons,
        clubId: 11,
      ),
      ClubEntity(
        id: '4i',
        name: '4 Iron',
        category: ClubCategory.irons,
        clubId: 12,
      ),
      ClubEntity(
        id: '5i',
        name: '5 Iron',
        category: ClubCategory.irons,
        clubId: 13,
      ),
      ClubEntity(
        id: '6i',
        name: '6 Iron',
        category: ClubCategory.irons,
        clubId: 14,
      ),
      ClubEntity(
        id: '7i',
        name: '7 Iron',
        category: ClubCategory.irons,
        clubId: 15,
      ),
      ClubEntity(
        id: '8i',
        name: '8 Iron',
        category: ClubCategory.irons,
        clubId: 16,
      ),
      ClubEntity(
        id: '9i',
        name: '9 Iron',
        category: ClubCategory.irons,
        clubId: 17,
      ),

      // WEDGES (IDs: 17-23)
      ClubEntity(
        id: 'pw',
        name: 'Pitching Wedge',
        category: ClubCategory.wedges,
        clubId: 18,
      ),
      ClubEntity(
        id: '50w',
        name: '50° Wedge',
        category: ClubCategory.wedges,
        clubId: 19,
      ),
      ClubEntity(
        id: '52w',
        name: '52° Wedge',
        category: ClubCategory.wedges,
        clubId: 20,
      ),
      ClubEntity(
        id: '54w',
        name: '54° Wedge',
        category: ClubCategory.wedges,
        clubId: 21,
      ),
      ClubEntity(
        id: '56w',
        name: '56° Wedge',
        category: ClubCategory.wedges,
        clubId: 22,
      ),
      ClubEntity(
        id: '58w',
        name: '58° Wedge',
        category: ClubCategory.wedges,
        clubId: 23,
      ),
      ClubEntity(
        id: '60w',
        name: '60° Wedge',
        category: ClubCategory.wedges,
        clubId: 24,
      ),
    ];
  }
}
