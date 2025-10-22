import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
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

import '../../../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import '../../domain/repositories/ble_repository.dart';

class GolfDeviceBloc extends Bloc<GolfDeviceEvent, GolfDeviceState> {
  final ScanDevicesUseCase scanDevicesUseCase;
  final ConnectDeviceUseCase connectDeviceUseCase;
  final DiscoverServicesUseCase discoverServicesUseCase;
  final SubscribeNotificationsUseCase subscribeNotificationsUseCase;
  final SendSyncPacketUseCase sendSyncPacketUseCase;
  final SendCommandUseCase sendCommandUseCase;
  final DisconnectDeviceUseCase disconnectDeviceUseCase;
  final BleRepository bleRepository;
  final SharedPreferences sharedPreferences;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _notificationSubscription;
  Timer? _syncTimer;
  Timer? _scanTimer;
  final Map<int, ShotAnalysisModel> _shotRecords = {};
  final List<DeviceEntity> _discoveredDevices = [];
  DeviceEntity? _connectedDevice;
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
  bool _hasWrittenInitialSync = false;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  final user = FirebaseAuth.instance.currentUser;

  GolfDeviceBloc({
    required this.scanDevicesUseCase,
    required this.connectDeviceUseCase,
    required this.discoverServicesUseCase,
    required this.subscribeNotificationsUseCase,
    required this.sendSyncPacketUseCase,
    required this.sendCommandUseCase,
    required this.disconnectDeviceUseCase,
    required this.bleRepository,
    required this.sharedPreferences,
  }) : super(GolfDeviceInitial()) {
    on<StartScanningEvent>(_onStartScanning);
    on<StopScanningEvent>(_onStopScanning);
    on<DeviceDiscoveredEvent>(_onDeviceDiscovered);
    on<ConnectToDeviceEvent>(_onConnectToDevice);
    on<ConnectionStateChangedEvent>(_onConnectionStateChanged);
    on<NotificationReceivedEvent>(_onNotificationReceived);
    on<SendSyncPacketEvent>(_onSendSyncPacket);
    on<UpdateClubEvent>(_onUpdateClub);
    on<ToggleUnitsEvent>(_onToggleUnits);
    on<SaveAllShotsEvent>(_onSaveAllShots);
    on<DisconnectDeviceEvent>(_onDisconnect);
    on<UpdateElapsedTimeEvent>(_onUpdateElapsedTime);
    on<LoadShotHistoryEvent>(_onLoadShotHistory);

    bleRepository.statusStream.listen((status) {
      if (status == BleStatus.ready) {
        add(StartScanningEvent());
      }
    });
  }

  Future<void> _onStartScanning(
    StartScanningEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    _discoveredDevices.clear();
    emit(ScanningState([]));

    await _scanSubscription?.cancel();
    _scanSubscription = scanDevicesUseCase.call().listen(
          (device) => add(DeviceDiscoveredEvent(device)),
        );

    _scanTimer?.cancel();
    _scanTimer = Timer(Duration(seconds: 1), () {
      add(StopScanningEvent());
    });
  }

  Future<void> _onStopScanning(
    StopScanningEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    await _scanSubscription?.cancel();
    _scanTimer?.cancel();
    scanDevicesUseCase.stop();
    emit(DevicesFoundState(List.from(_discoveredDevices)));
  }

  void _onDeviceDiscovered(
    DeviceDiscoveredEvent event,
    Emitter<GolfDeviceState> emit,
  ) {
    final index = _discoveredDevices.indexWhere((d) => d.id == event.device.id);
    if (index >= 0) {
      _discoveredDevices[index] = event.device;
    } else {
      _discoveredDevices.add(event.device);
    }
    emit(ScanningState(List.from(_discoveredDevices)));
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

  Future<void> _onConnectToDevice(
    ConnectToDeviceEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    emit(ConnectingState(List.from(_discoveredDevices)));
    _connectedDevice = event.device;

    await _connectionSubscription?.cancel();
    _connectionSubscription = connectDeviceUseCase.call(event.device.id).listen(
      (state) {
        add(ConnectionStateChangedEvent(state));
      },
    );
  }

  Future<void> _onConnectionStateChanged(
    ConnectionStateChangedEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    if (event.state == DeviceConnectionState.connected &&
        _connectedDevice != null) {
      _hasWrittenInitialSync = false;
      try {
        await discoverServicesUseCase.call(_connectedDevice!.id);

        await _notificationSubscription?.cancel();
        _notificationSubscription = subscribeNotificationsUseCase.call().listen(
              (data) => add(NotificationReceivedEvent(data)),
            );

        _startSyncTimer();

        _startElapsedTimer();

        emit(ConnectedState(
          device: _connectedDevice!,
          golfData: _golfData,
          units: _units,
          currentDate: _formattedDate(),
          elapsedTime: _formatElapsedTime(_elapsedSeconds),
        ));

        if (!_hasWrittenInitialSync) {
          _hasWrittenInitialSync = true;
          Future.delayed(Duration(milliseconds: 100), () {
            add(SendSyncPacketEvent());
          });
        }
      } catch (e) {
        emit(ErrorState('Failed to setup connection: $e'));
      }
    } else if (event.state == DeviceConnectionState.disconnected) {
      await _notificationSubscription?.cancel();
      _syncTimer?.cancel();
      _elapsedTimer?.cancel();
      _connectedDevice = null;
      _hasWrittenInitialSync = false;
      emit(DisconnectedState(List.from(_discoveredDevices)));
    }
  }

  void _onNotificationReceived(
    NotificationReceivedEvent event,
    Emitter<GolfDeviceState> emit,
  ) {
    final data = event.data;

    if (data.length >= 3) {
      switch (data[2]) {
        case 0x01:
          if (data.length >= 16) {
            _parseGolfData(Uint8List.fromList(data));
            _storeShotData(_golfData);
            if (state is ConnectedState) {
              emit((state as ConnectedState).copyWith(golfData: _golfData));
            }
          }
          break;
        case 0x02:
          if (state is ConnectedState) {
            final currentState = state as ConnectedState;
            emit(ClubUpdatedState(
              device: currentState.device,
              golfData: currentState.golfData,
              units: currentState.units,
            ));
          }
          break;
        case 0x04:
          _units = !_units;
          if (state is ConnectedState) {
            emit((state as ConnectedState).copyWith(units: _units));
          }
          break;
      }
    }
  }

  Future<void> _onSendSyncPacket(
    SendSyncPacketEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    if (state is ConnectedState && !(state as ConnectedState).isLoading) {
      try {
        await sendSyncPacketUseCase.call(_golfData.clubName);
      } catch (e) {
        emit(ErrorState('Failed to send sync packet: $e'));
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
        await sendCommandUseCase.call(0x02, event.clubId, 0x00);
      } catch (e) {
        emit(ErrorState('Failed to update club: $e'));
      }
    }
  }

  void _onToggleUnits(
    ToggleUnitsEvent event,
    Emitter<GolfDeviceState> emit,
  ) {
    if (state is ConnectedState) {
      _units = !_units;
      emit((state as ConnectedState).copyWith(units: _units));
    }
  }

  Future<void> _onDisconnect(
    DisconnectDeviceEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    try {
      if (event.navigateToLanding) {
        emit(DisconnectingState());
      }
      // await _saveToLocal();
      await _saveAllShotsToFirebase();
      await disconnectDeviceUseCase.call();
      await _notificationSubscription?.cancel();
      _syncTimer?.cancel();
      _connectedDevice = null;
      _hasWrittenInitialSync = false;
      if (event.navigateToLanding) {
        emit(NavigateToLandDashboardState());
      }
    } catch (e) {
      print(e);
      emit(ErrorState('Failed to disconnect: $e'));
    }
  }

  Future<void> _onSaveAllShots(
    SaveAllShotsEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    emit(GolfDeviceSaveDataLoading());
    await _saveAllShotsToFirebase();
    emit(GolfDeviceSaveSuccessState());
  }

  Future<void> _saveAllShotsToFirebase() async {
    if (_shotRecords.isEmpty) {
      print("⚠️ No shots to save");
      return;
    }

    print("💾 Saving ${_shotRecords.length} shots to Firebase...");

    try {
      for (var shotModel in _shotRecords.values) {
        await bleRepository.saveShot(shotModel);
      }
      print("✅ All shots saved successfully!");
      _shotRecords.clear();
    } catch (e) {
      print("❌ Error saving shots: $e");
    }
  }

  Future<void> _onLoadShotHistory(
    LoadShotHistoryEvent event,
    Emitter<GolfDeviceState> emit,
  ) async {
    emit(ShotHistoryLoadingState());
    try {
      final userId = user?.uid ?? '';
      if (userId.isEmpty) {
        emit(ShotHistoryErrorState('User not authenticated'));
        return;
      }

      final shots = await bleRepository.fetchShotsForUser(userId);
      emit(ShotHistoryLoadedState(shots));
    } catch (e) {
      emit(ShotHistoryErrorState(e.toString()));
    }
  }

  // Future<void> _saveToLocal() async {
  //   try {
  //     final sessionTime = _formatElapsedTime(_elapsedSeconds);
  //
  //     // Convert shot records to a JSON-serializable format
  //     final updatedRecords = <String, dynamic>{};
  //
  //     _shotRecords.forEach((key, value) {
  //       // Convert the integer key to string for JSON compatibility
  //       final shotKey = key.toString();
  //
  //       updatedRecords[shotKey] = {
  //         'date': value['date']?.toString() ?? '',
  //         'time': value['time']?.toString() ?? '',
  //         'clubName': value['clubName'] is int ? value['clubName'] : (value['clubName'] as num?)?.toInt() ?? 0,
  //         'clubSpeed': value['clubSpeed'] is double ? value['clubSpeed'] : (value['clubSpeed'] as num?)?.toDouble() ?? 0.0,
  //         'ballSpeed': value['ballSpeed'] is double ? value['ballSpeed'] : (value['ballSpeed'] as num?)?.toDouble() ?? 0.0,
  //         'carryDistance': value['carryDistance'] is double ? value['carryDistance'] : (value['carryDistance'] as num?)?.toDouble() ?? 0.0,
  //         'totalDistance': value['totalDistance'] is double ? value['totalDistance'] : (value['totalDistance'] as num?)?.toDouble() ?? 0.0,
  //         'shotNumber': value['shotNumber'] is int ? value['shotNumber'] : (value['shotNumber'] as num?)?.toInt() ?? 0,
  //         'sessionTime': sessionTime,
  //       };
  //     });
  //
  //     // Save JSON string
  //     final jsonString = jsonEncode(updatedRecords);
  //     await sharedPreferences.setString('shot_records', jsonString);
  //
  //     print("💾 Shot data saved locally with session time. Total shots: ${updatedRecords.length}");
  //   } catch (e, stack) {
  //     print("❌ Error saving local shot data: $e");
  //     print(stack);
  //   }
  // }

  // Future<Map<int, Map<String, dynamic>>> loadShotRecordsFromLocal() async {
  //   try {
  //     final jsonString = sharedPreferences.getString('shot_records');
  //
  //     if (jsonString == null || jsonString.isEmpty) {
  //       print("📭 No shot records found in local storage");
  //       return {};
  //     }
  //
  //     final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
  //     final Map<int, Map<String, dynamic>> shotRecords = {};
  //
  //     decoded.forEach((key, value) {
  //       final recordNumber = int.tryParse(key);
  //       if (recordNumber != null && value is Map) {
  //         shotRecords[recordNumber] = Map<String, dynamic>.from(value as Map);
  //       }
  //     });
  //
  //     print("📂 Loaded ${shotRecords.length} shot records from local storage");
  //     return shotRecords;
  //   } catch (e, stack) {
  //     print("❌ Error loading shot data: $e");
  //     print(stack);
  //     return {};
  //   }
  // }

  // Future<List<Map<String, dynamic>>> getFormattedShotHistory() async {
  //   try {
  //     final records = await loadShotRecordsFromLocal();
  //
  //     final sortedShots = records.entries
  //         .map((entry) => entry.value)
  //         .toList()
  //       ..sort((a, b) => (b['shotNumber'] as int).compareTo(a['shotNumber'] as int));
  //
  //     return sortedShots;
  //   } catch (e) {
  //     print("❌ Error getting formatted shot history: $e");
  //     return [];
  //   }
  // }
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (state is ConnectedState && !(state as ConnectedState).isLoading) {
        add(SendSyncPacketEvent());
      }
    });
  }

  void _parseGolfData(Uint8List data) {
    if (data[0] != 0x47 || data[1] != 0x46) return;

    _golfData = GolfDataEntity(
      battery: data[3],
      recordNumber: (data[4] << 8) | data[5],
      clubName: data[6],
      clubSpeed: ((data[7] << 8) | data[8]) / 10.0,
      ballSpeed: ((data[9] << 8) | data[10]) / 10.0,
      carryDistance: ((data[11] << 8) | data[12]) / 10.0,
      totalDistance: ((data[13] << 8) | data[14]) / 10.0,
    );
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
    );

    if (_shotRecords.containsKey(data.recordNumber)) {
      _shotRecords[data.recordNumber] = shotModel;
    } else {
      _shotRecords[data.recordNumber] = shotModel;
    }
    print("📊 Stored Shots: $_shotRecords");
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedSeconds = 0;

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      add(UpdateElapsedTimeEvent());
    });
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
  Future<void> close() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _notificationSubscription?.cancel();
    _syncTimer?.cancel();
    _scanTimer?.cancel();
    _elapsedTimer?.cancel();
    _scanTimer?.cancel();
    return super.close();
  }
}
