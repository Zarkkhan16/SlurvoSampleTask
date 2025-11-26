import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:onegolf/feature/golf_device/data/datasources/shot_firestore_datasource.dart';
import 'package:onegolf/feature/golf_device/data/model/shot_anaylsis_model.dart';
import 'package:onegolf/feature/golf_device/domain/entities/device_entity.dart';
import 'package:onegolf/feature/golf_device/domain/entities/golf_data_entities.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/connect_device_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/disconnect_device_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/discover_services_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/scan_devices_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/send_command_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/send_sync_packet_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/subscribe_notifications_usecase.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_event.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../ble_management/domain/repositories/ble_management_repository.dart';
import '../../../widget/custom_app_bar.dart';
import '../../domain/repositories/ble_repository.dart';

class GolfDeviceBloc extends Bloc<GolfDeviceEvent, GolfDeviceState> {
  final BleManagementRepository bleRepository;
  final ShotFirestoreDatasource datasource;
  final SharedPreferences sharedPreferences;
  StreamSubscription? _notificationSubscription;
  Timer? _syncTimer;
  final Map<int, ShotAnalysisModel> _shotRecords = {};
  final Map<int, ShotAnalysisModel> _sessionData = {};
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
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  final user = FirebaseAuth.instance.currentUser;
  final _bleResponseController = StreamController<List<int>>.broadcast();

  Stream<List<int>> get bleResponseStream => _bleResponseController.stream;

  GolfDeviceBloc({
    required this.bleRepository,
    required this.sharedPreferences,
    required this.datasource,
  }) : super(GolfDeviceInitial()) {
    on<ConnectionStateChangedEvent>(_onConnectionStateChanged);
    on<NotificationReceivedEvent>(_onNotificationReceived);
    on<SendSyncPacketEvent>(_onSendSyncPacket);
    on<UpdateClubEvent>(_onUpdateClub);
    on<SaveAllShotsEvent>(_onSaveAllShots);
    on<DisconnectDeviceEvent>(_onDisconnect);
    on<UpdateElapsedTimeEvent>(_onUpdateElapsedTime);
    on<ReturnToConnectedStateEvent>(_onReturnToConnectedState);
    on<DeleteLatestShotEvent>(_onDeleteLatestShot);
    on<UpdateMetricFilterEvent>(_onUpdateMetricFilter);

    add(ConnectionStateChangedEvent(bleRepository.isConnected));
  }

  Future<void> _onUpdateMetricFilter(
    UpdateMetricFilterEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    if (state is ConnectedState) {
      final currentState = state as ConnectedState;
      emit(currentState.copyWith(selectedMetrics: event.selectedMetrics));
    }
  }

  Future<void> _onUpdateElapsedTime(
      UpdateElapsedTimeEvent event,
      Emitter<GolfDeviceState> emit,
      ) async {
    if (state is ConnectedState) {
      final currentState = state as ConnectedState;
      emit(currentState.copyWith(
        currentDate: _formattedDate(),
        elapsedTime: _formatElapsedTime(_elapsedSeconds),
      ));
    }
  }

  // Future<void> _onStartScanning(
  //   StartScanningEvent event,
  //   Emitter<GolfDeviceState> emit,
  // ) async {
  //   _discoveredDevices.clear();
  //   emit(ScanningState([]));
  //
  //   await _scanSubscription?.cancel();
  //   _scanSubscription = scanDevicesUseCase.call().listen(
  //         (device) => add(DeviceDiscoveredEvent(device)),
  //       );
  //
  //   _scanTimer?.cancel();
  //   _scanTimer = Timer(Duration(seconds: 1), () {
  //     add(StopScanningEvent());
  //   });
  // }

  // Future<void> _onStopScanning(
  //   StopScanningEvent event,
  //   Emitter<GolfDeviceState> emit,
  // ) async {
  //   await _scanSubscription?.cancel();
  //   _scanTimer?.cancel();
  //   scanDevicesUseCase.stop();
  //   emit(DevicesFoundState(List.from(_discoveredDevices)));
  // }

  // void _onDeviceDiscovered(
  //   DeviceDiscoveredEvent event,
  //   Emitter<GolfDeviceState> emit,
  // ) {
  //   final index = _discoveredDevices.indexWhere((d) => d.id == event.device.id);
  //   if (index >= 0) {
  //     _discoveredDevices[index] = event.device;
  //   } else {
  //     _discoveredDevices.add(event.device);
  //   }
  //   emit(ScanningState(List.from(_discoveredDevices)));
  // }

  // Future<void> _onConnectToDevice(
  //   ConnectToDeviceEvent event,
  //   Emitter<GolfDeviceState> emit,
  // ) async {
  //   emit(ConnectingState(List.from(_discoveredDevices)));
  //   _connectedDevice = event.device;
  //
  //   await _connectionSubscription?.cancel();
  //   _connectionSubscription = connectDeviceUseCase.call(event.device.id).listen(
  //     (state) {
  //       add(ConnectionStateChangedEvent(state));
  //     },
  //   );
  // }

  Future<void> _onConnectionStateChanged(
    ConnectionStateChangedEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    if (event.isConnected == bleRepository.isConnected) {
      final deviceId = bleRepository.connectedDeviceId;
      try {
        if (deviceId != null) {
          print('🔍 Re-discovering services...');
          await bleRepository.discoverServices(deviceId);
          print('✅ Services discovered');
          await Future.delayed(Duration(milliseconds: 500));
        }

        await _notificationSubscription?.cancel();
        _notificationSubscription =
            bleRepository.subscribeToNotifications().listen(
                  (data) => add(NotificationReceivedEvent(data)),
                );

        _startSyncTimer();

        _startElapsedTimer();

        emit(ConnectedState(
          deviceId: deviceId!,
          golfData: _golfData,
          units: _units,
          currentDate: _formattedDate(),
          elapsedTime: _formatElapsedTime(_elapsedSeconds),
        ));
      } catch (e) {
        emit(ErrorState('Failed to setup connection: $e'));
      }
    }
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(seconds: 02), (_) {
      if (bleRepository.isConnected) {
        add(SendSyncPacketEvent());
      }
    });
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedSeconds = 0;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      add(UpdateElapsedTimeEvent());
    });
  }

  Future<void> _onSendSyncPacket(
    SendSyncPacketEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    if (bleRepository.isConnected) {
      try {
        int checksum = (0x01 + _golfData.clubName) & 0xFF;
        bleRepository.writeData([0x47, 0x46, 0x01, _golfData.clubName, 0x00, checksum]);
      } catch (e) {
        emit(ErrorState('Failed to send sync packet: $e'));
      }
    }
  }

  void _onNotificationReceived(
    NotificationReceivedEvent event,
    Emitter<GolfDeviceState> emit,
  ) {
    final data = event.data;

    _bleResponseController.add(data);

    if (data.length >= 3) {
      switch (data[2]) {
        case 0x01:
          if (data.length >= 16) {
            _parseGolfData(Uint8List.fromList(data));
            _storeShotData(_golfData);
            if (state is ConnectedState) {
              emit((state as ConnectedState).copyWith(
                golfData: _golfData,
                units: _units,
              ));
            }
          }
          break;
        case 0x02:
          if (state is ConnectedState) {
            final currentState = state as ConnectedState;
            emit(ClubUpdatedState(
              golfData: currentState.golfData,
              units: currentState.units,
            ));
          }
          break;
        case 0x04:
          _units = !_units;
          if (state is ConnectedState) {
            double newCarryDistance;
            double newTotalDistance;

            if (_units) {
              newCarryDistance = _golfData.carryDistance * 0.9144;
              newTotalDistance = _golfData.totalDistance * 0.9144;
            } else {
              newCarryDistance = _golfData.carryDistance * 1.093613298;
              newTotalDistance = _golfData.totalDistance * 1.093613298;
            }

            _golfData = _golfData.copyWith(
              carryDistance: newCarryDistance,
              totalDistance: newTotalDistance,
            );

            emit((state as ConnectedState).copyWith(
              units: _units,
              golfData: _golfData,
            ));
          }
          break;
      }
    }
  }

  Future<void> _onUpdateClub(
    UpdateClubEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    if (state is ConnectedState) {
      final currentState = state as ConnectedState;
      _golfData = _golfData.copyWith(clubName: event.clubId);

      emit(currentState.copyWith(
        golfData: _golfData,
        isLoading: true,
      ));

      try {
        List<int> packet = [0x47, 0x46, 0x02, event.clubId, 0x00];
        bleRepository.writeData(packet);
      } catch (e) {
        emit(ErrorState('Failed to update club: $e'));
      }
    }
  }

  Future<void> _onDisconnect(
    DisconnectDeviceEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    try {
      emit(DisconnectingState());
      await _saveAllShotsToFirebase();

      if (_sessionData.isNotEmpty) {
        final sessionSummary = _generateSessionSummary();
        print("📊 SESSION SUMMARY:");
        print(sessionSummary);
      }
      emit(NavigateToSessionSummaryState(summaryData: sessionSummary));
      await _notificationSubscription?.cancel();
      _notificationSubscription = null;
      _syncTimer?.cancel();
      _sessionData.clear();
      _elapsedTimer?.cancel();
    } catch (e) {
      print(e);
      emit(ErrorState('Failed to disconnect: $e'));
    }
  }

  Future<void> _onSaveAllShots(
      SaveAllShotsEvent event,
      Emitter<GolfDeviceState> emit,
      ) async {
    if (_shotRecords.isNotEmpty) {
      emit(SaveDataLoading());
      await _saveAllShotsToFirebase();
    }
    emit(SaveShotsSuccessfully());
  }

  Future<void> _saveAllShotsToFirebase() async {
    if (_shotRecords.isEmpty) {
      print("⚠️ No shots to save");
      return;
    }

    print("💾 Saving ${_shotRecords.length} shots to Firebase...");

    try {
      final sortedKeys = _shotRecords.keys.toList()..sort();
      final latestKey = sortedKeys.last;
      final latestShot = _shotRecords[latestKey];

      for (var shotModel in _shotRecords.values) {
        ShotAnalysisModel shotToSave;

        if (shotModel.isMeter) {
          shotToSave = shotModel.copyWith(
            carryDistance: shotModel.carryDistance * 1.093613298,
            totalDistance: shotModel.totalDistance * 1.093613298,
            isMeter: false,
          );
          print("🔄 Converted & Saved Shot #${shotModel.shotNumber}: "
              "${shotModel.carryDistance}M → ${shotToSave.carryDistance.toStringAsFixed(1)}YD");
        } else {
          shotToSave = shotModel;
          print("✅ Saved Shot #${shotModel.shotNumber} (already in yards)");
        }

        // Save to Firebase
        await datasource.saveShot(shotToSave);
        _sessionData[shotModel.shotNumber] = shotToSave;
      }

      print("✅ All shots saved successfully!");
      print("📦 Total Session Shots: ${_sessionData.length}");

      // _shotRecords
      //   ..clear();
      //   ..[latestKey] = latestShot!;
      _shotRecords.clear();
    } catch (e) {
      print("❌ Error saving shots: $e");
    }
  }

  Map<String, dynamic> _generateSessionSummary() {
    if (_sessionData.isEmpty) return {};

    final shots = _sessionData.values.toList();
    Map<int, List<ShotAnalysisModel>> shotsByClub = {};
    for (var shot in shots) {
      if (!shotsByClub.containsKey(shot.clubName)) {
        shotsByClub[shot.clubName] = [];
      }
      shotsByClub[shot.clubName]!.add(shot);
    }

    List<Map<String, dynamic>> shotAverages = [];
    shotsByClub.forEach((clubName, clubShots) {
      double avgClubSpeed =
          clubShots.map((s) => s.clubSpeed).reduce((a, b) => a + b) /
              clubShots.length;
      double avgBallSpeed =
          clubShots.map((s) => s.ballSpeed).reduce((a, b) => a + b) /
              clubShots.length;
      double avgCarryDistance =
          clubShots.map((s) => s.carryDistance).reduce((a, b) => a + b) /
              clubShots.length;
      double avgTotalDistance =
          clubShots.map((s) => s.totalDistance).reduce((a, b) => a + b) /
              clubShots.length;

      double clubSpeedStdDev = _calculateStdDev(
          clubShots.map((s) => s.clubSpeed).toList(), avgClubSpeed);
      double ballSpeedStdDev = _calculateStdDev(
          clubShots.map((s) => s.ballSpeed).toList(), avgBallSpeed);
      double carryStdDev = _calculateStdDev(
          clubShots.map((s) => s.carryDistance).toList(), avgCarryDistance);
      double totalStdDev = _calculateStdDev(
          clubShots.map((s) => s.totalDistance).toList(), avgTotalDistance);

      shotAverages.add({
        'clubName': clubName,
        'clubDisplayName': AppStrings.clubs[clubName] ?? 'Unknown',
        'avgClubSpeed': avgClubSpeed,
        'clubSpeedStdDev': clubSpeedStdDev,
        'avgBallSpeed': avgBallSpeed,
        'ballSpeedStdDev': ballSpeedStdDev,
        'avgCarryDistance': avgCarryDistance,
        'carryStdDev': carryStdDev,
        'avgTotalDistance': avgTotalDistance,
        'totalStdDev': totalStdDev,
        'shotCount': clubShots.length,
      });
    });

    // 2. Session Summary
    int totalBalls = shots.length;
    String sessionTime = _formatElapsedTime(_elapsedSeconds);
    int clubsUsed = shotsByClub.keys.length;

    // 3. Shot Summary (individual shots with carry distance)
    List<Map<String, dynamic>> shotSummary = [];
    for (int i = 0; i < shots.length; i++) {
      shotSummary.add({
        'shotNumber': i + 1,
        'carryDistance': shots[i].carryDistance,
        'clubName': shots[i].clubName,
        'clubDisplayName': AppStrings.clubs[shots[i].clubName] ?? 'Unknown',
      });
    }

    return {
      'shotAverages': shotAverages,
      'sessionSummary': {
        'totalBalls': totalBalls,
        'sessionTime': sessionTime,
        'clubsUsed': clubsUsed,
      },
      'shotSummary': shotSummary,
    };
  }

  double _calculateStdDev(List<double> values, double mean) {
    if (values.length <= 1) return 0.0;

    double sumSquaredDiff = 0;
    for (var value in values) {
      sumSquaredDiff += (value - mean) * (value - mean);
    }

    return sqrt(sumSquaredDiff / values.length);
  }

  Map<String, dynamic> get sessionSummary => _generateSessionSummary();

  Future<void> _onReturnToConnectedState(
    ReturnToConnectedStateEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    if (bleRepository.isConnected) {
      if (_shotRecords.isNotEmpty) {
        final latestShot = _shotRecords.values.first;

        _golfData = _golfData.copyWith(
          clubName: latestShot.clubName,
          clubSpeed: latestShot.clubSpeed,
          ballSpeed: latestShot.ballSpeed,
          carryDistance: latestShot.carryDistance,
          totalDistance: latestShot.totalDistance,
          recordNumber: latestShot.shotNumber,
        );
      } else {
        _golfData = _golfData.copyWith(
          clubSpeed: 0.0,
          ballSpeed: 0.0,
          carryDistance: 0.0,
          totalDistance: 0.0,
          recordNumber: 0,
        );
      }

      emit(ConnectedState(
        golfData: _golfData,
        units: _units,
        currentDate: _formattedDate(),
        elapsedTime: _formatElapsedTime(_elapsedSeconds),
      ));
    }
  }

  void _parseGolfData(Uint8List data) {
    if (data[0] != 0x47 || data[1] != 0x46) return;

    bool isMeters = (data[11] & 0x80) != 0;

    int carryHigh = data[11] & 0x7F;
    int carryLow = data[12];
    double carryDistance = ((carryHigh << 8) | carryLow) / 10.0;

    _golfData = GolfDataEntity(
      battery: data[3],
      recordNumber: (data[4] << 8) | data[5],
      clubName: data[6],
      clubSpeed: ((data[7] << 8) | data[8]) / 10.0,
      ballSpeed: ((data[9] << 8) | data[10]) / 10.0,
      carryDistance: carryDistance,
      totalDistance: ((data[13] << 8) | data[14]) / 10.0,
    );

    _units = isMeters;
    print("📊 Parsed Golf Data:");
    print("   Record: ${_golfData.recordNumber}");
    print("   Club: ${_golfData.clubName}");
    print("   Carry: ${_golfData.carryDistance} ${isMeters ? 'M' : 'YD'}");
    print("   Total: ${_golfData.totalDistance}");
    print("   Unit Mode: ${isMeters ? 'METERS' : 'YARDS'}");
  }

  void _storeShotData(GolfDataEntity data) {
    final now = DateTime.now();
    final date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    String formatElapsedTime(int seconds) {
      final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
      final secs = (seconds % 60).toString().padLeft(2, '0');
      return "$hours:$minutes:$secs";
    }

    final sessionTime = formatElapsedTime(_elapsedSeconds);
    final userUid = user?.uid ?? '';

    if (data.recordNumber == 0) {
      return;
    }

    final shotModel = ShotAnalysisModel(
      id: '',
      userUid: userUid,
      shotNumber: data.recordNumber,
      clubName: data.clubName,
      clubSpeed: data.clubSpeed,
      ballSpeed: data.ballSpeed,
      smashFactor: data.smashFactor,
      carryDistance: data.carryDistance,
      totalDistance: data.totalDistance,
      date: date,
      time: time,
      sessionTime: sessionTime,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isMeter: _units,
    );

    _shotRecords[data.recordNumber] = shotModel;
    _sessionData[data.recordNumber] = shotModel;

    print("📊 Stored Shots: $_shotRecords");
    print("📦 Session Data Count: ${_sessionData.length}");
  }

  Future<void> _onDeleteLatestShot(
    DeleteLatestShotEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    if (_shotRecords.isEmpty) return;

    // Sort keys to identify latest shot number
    final sortedKeys = _shotRecords.keys.toList()..sort();

    // Latest shot number
    final latestKey = sortedKeys.last;
    _shotRecords.remove(latestKey);
    _sessionData.remove(latestKey);

    print("🗑️ Deleted Shot #$latestKey");

    if (_shotRecords.isNotEmpty) {
      final prevKey = sortedKeys.length > 1
          ? sortedKeys[sortedKeys.length - 2]
          : sortedKeys.first;
      final prevShot = _shotRecords[prevKey];

      _golfData = _golfData.copyWith(
        clubName: prevShot!.clubName,
        clubSpeed: prevShot.clubSpeed,
        ballSpeed: prevShot.ballSpeed,
        carryDistance: prevShot.carryDistance,
        totalDistance: prevShot.totalDistance,
        recordNumber: prevShot.shotNumber,
      );

      if (state is ConnectedState) {
        final currentState = state as ConnectedState;
        emit(currentState.copyWith(golfData: _golfData));
      }
    } else {
      _golfData = _golfData.copyWith(
        clubSpeed: 0.0,
        ballSpeed: 0.0,
        carryDistance: 0.0,
        totalDistance: 0.0,
        recordNumber: 0,
      );

      if (state is ConnectedState) {
        final currentState = state as ConnectedState;
        emit(currentState.copyWith(golfData: _golfData));
      }
    }
  }

  ShotAnalysisModel? get latestShot {
    if (_shotRecords.isEmpty) return null;
    final sortedKeys = _shotRecords.keys.toList()..sort();
    return _shotRecords[sortedKeys.last];
  }

  String _formattedDate() {
    final now = DateTime.now();
    return "${_weekdayName(now.weekday)}, ${now.day} ${_monthName(now.month)} ${now.year}";
  }

  String _weekdayName(int weekday) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return names[weekday - 1];
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  String _formatElapsedTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}:"
          "${secs.toString().padLeft(2, '0')} hr";
    } else if (minutes > 0) {
      return "${minutes.toString().padLeft(2, '0')}:"
          "${secs.toString().padLeft(2, '0')} min";
    } else {
      return "${secs.toString().padLeft(2, '0')} sec";
    }
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _syncTimer?.cancel();
    _elapsedTimer?.cancel();
    return super.close();
  }
}
