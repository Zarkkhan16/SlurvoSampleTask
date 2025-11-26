import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_event.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_state.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../ble_management/domain/repositories/ble_management_repository.dart';
import '../../../golf_device/domain/entities/golf_data_entities.dart';

class PracticeGamesBloc extends Bloc<PracticeGamesEvent, PracticeGamesState> {
  final BleManagementRepository bleRepository;
  StreamSubscription? _notificationSubscription;
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

  final List<GolfDataEntity> _golfDataListItem = [];
  final GolfDataEntity? bestShot = null;
  bool _units = false;
  Timer? _syncTimer;

  PracticeGamesBloc({required this.bleRepository})
      : super(PracticeGamesState()) {
    on<SelectShotsEvent>(_onSelectShots);
    on<SelectCustomEvent>(_onSelectCustom);
    on<UpdateCustomShotsEvent>(_onUpdateCustomShots);
    on<AddPlayerEvent>(_onAddPlayer);
    on<EditPlayerEvent>(_onEditPlayer);
    on<RemovePlayerEvent>(_onRemovePlayer);
    on<NextAttemptEvent>(_onNextAttempt);
    on<SessionEndAttemptEvent>(_onSessionEndAttempt);
    on<ResetSessionEvent>(_onResetSession);

    on<StartListeningToBleDataEvent>(_onStartListeningToBleData);
    on<StopListeningToBleDataEvent>(_onStopListeningToBleData);
    on<SendBleCommandEvent>(_onSendBleCommand);
    on<BleDataReceivedEvent>(_onBleDataReceived);
  }

  void _onSelectShots(
      SelectShotsEvent event, Emitter<PracticeGamesState> emit) {
    emit(state.copyWith(
      selectedShots: event.shots,
      isCustomSelected: false,
    ));
  }

  void _onSelectCustom(
      SelectCustomEvent event, Emitter<PracticeGamesState> emit) {
    emit(state.copyWith(
      isCustomSelected: true,
      selectedShots: 0,
    ));
  }

  void _onUpdateCustomShots(
      UpdateCustomShotsEvent event, Emitter<PracticeGamesState> emit) {
    final num? entered = int.tryParse(event.value);
    if (entered != null && entered <= 10) {
      emit(state.copyWith(selectedShots: entered.toInt()));
    }
  }

  void _onAddPlayer(AddPlayerEvent event, Emitter<PracticeGamesState> emit) {
    if (state.canAddPlayer) {
      final updatedPlayers = List<String>.from(state.players)
        ..add(event.playerName);
      emit(state.copyWith(players: updatedPlayers));
    }
  }

  void _onEditPlayer(EditPlayerEvent event, Emitter<PracticeGamesState> emit) {
    if (event.playerIndex >= 0 && event.playerIndex < state.players.length) {
      final updatedPlayers = List<String>.from(state.players);
      final oldName = updatedPlayers[event.playerIndex];
      updatedPlayers[event.playerIndex] = event.newName;

      emit(state.copyWith(players: updatedPlayers));
    }
  }

  void _onRemovePlayer(
      RemovePlayerEvent event, Emitter<PracticeGamesState> emit) {
    if (event.playerIndex >= 0 && event.playerIndex < state.players.length) {
      final updatedPlayers = List<String>.from(state.players)
        ..removeAt(event.playerIndex);

      emit(state.copyWith(players: updatedPlayers));
    }
  }

  void _onNextAttempt(
      NextAttemptEvent event, Emitter<PracticeGamesState> emit) {
    emit(state.copyWith(currentAttempt: state.currentAttempt + 1));
  }

  void _onSessionEndAttempt(
      SessionEndAttemptEvent event, Emitter<PracticeGamesState> emit) {
    if (state.latestBleData.isEmpty) {
      emit(state.copyWith(bestShot: null));
    }

    final limitedList = state.latestBleData.take(state.currentAttempt).toList();

    final bestShot = limitedList.reduce(
          (a, b) => a.totalDistance > b.totalDistance ? a : b,
    );

    emit(state.copyWith(bestShot: bestShot));
  }

  void _onResetSession(
      ResetSessionEvent event, Emitter<PracticeGamesState> emit) {
    _golfDataListItem.clear();
    emit(state.copyWith(
      currentAttempt: 1,
      selectedShots: 3,
      isCustomSelected: false,
      players: [AppStrings.userProfileData.name],
      latestBleData: [],
      bestShot: null,
    ));
  }

  Future<void> _onStartListeningToBleData(
    StartListeningToBleDataEvent event,
    Emitter<PracticeGamesState> emit,
  ) async {
    print('🎮 Starting BLE listener...');

    if (!bleRepository.isConnected) {
      print('❌ Not connected');
      return;
    }

    // ⭐ KEY FIX: Re-discover services before subscribing
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
      emit(state.copyWith(bleError: 'Service discovery failed'));
      return;
    }

    // Now subscribe
    await _notificationSubscription?.cancel();
    _notificationSubscription = bleRepository.subscribeToNotifications().listen(
      (data) {
        print('📡 BLE Data received: $data');
        add(BleDataReceivedEvent(data));
      },
      onError: (error) {
        print('❌ BLE error: $error');
      },
      onDone: () {
        print('⚠️ Stream closed');
      },
    );

    emit(state.copyWith(isListeningToBle: true));

    _startSyncTimer();
    print('✅ Listener started');
  }

  Future<void> _onStopListeningToBleData(
    StopListeningToBleDataEvent event,
    Emitter<PracticeGamesState> emit,
  ) async {
    print('🎮 Practice Games: Stopping BLE listener...');

    await _notificationSubscription?.cancel();
    _notificationSubscription = null;

    _syncTimer?.cancel();
    _syncTimer = null;

    _golfDataListItem.clear();
    emit(state.copyWith(
      isListeningToBle: false,
      currentAttempt: 1,
    ));

    print('✅ BLE listener stopped');
  }

  Future<void> _onSendBleCommand(
    SendBleCommandEvent event,
    Emitter<PracticeGamesState> emit,
  ) async {
    print('🎮 Practice Games: Sending BLE command...');
    print('   Command: ${event.command}');

    try {
      if (!bleRepository.isConnected) {
        print('❌ Device not connected!');
        emit(state.copyWith(bleError: 'Device not connected'));
        return;
      }
      await bleRepository.writeData(event.command);

      print('✅ Command sent successfully');
      emit(state.copyWith(bleError: null));
    } catch (e) {
      print('❌ Failed to send command: $e');
      emit(state.copyWith(bleError: 'Failed to send: $e'));
    }
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

  void _onBleDataReceived(
    BleDataReceivedEvent event,
    Emitter<PracticeGamesState> emit,
  ) {
    print('🎮 Practice Games: Processing BLE data...');
    try {
      _bleDataController.add(event.data);
      _parseGolfData(Uint8List.fromList(event.data));
      _golfDataListItem.add(_golfData);
      emit(state.copyWith(
        latestBleData: _golfDataListItem,
        bleError: null,
      ));
    } catch (e) {
      print('❌ Failed to parse BLE data: $e');
      emit(state.copyWith(bleError: 'Data parsing error: $e'));
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
}
