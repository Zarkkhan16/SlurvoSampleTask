// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:onegolf/feature/ble_management/domain/entities/ble_device_entity.dart';
// import 'package:onegolf/feature/golf_device/domain/entities/device_entity.dart';
// import '../../../golf_device/domain/usecases/connect_device_usecase.dart';
// import '../../../golf_device/domain/usecases/disconnect_device_usecase.dart';
// import '../../../golf_device/domain/usecases/discover_services_usecase.dart';
// import '../../../golf_device/domain/usecases/scan_devices_usecase.dart';
// import '../../domain/usecases/check_connection_status_usecase.dart';
// import 'ble_management_event.dart';
// import 'ble_management_state.dart';
//
// class BleManagementBloc extends Bloc<BleManagementEvent, BleManagementState> {
//   final ScanDevicesUseCase scanDevicesUseCase;
//   final ConnectDeviceUseCase connectDeviceUseCase;
//   final DisconnectDeviceUseCase disconnectDeviceUseCase;
//   final DiscoverServicesUseCase discoverServicesUseCase;
//   final CheckConnectionStatusUseCase checkConnectionStatusUseCase;
//
//   StreamSubscription? _scanSubscription;
//   StreamSubscription? _connectionSubscription;
//   StreamSubscription? _bleStatusSubscription;
//   Timer? _scanTimer;
//
//   final List<DeviceEntity> _discoveredDevices = [];
//   String? _currentDeviceId;
//   String? _currentDeviceName;
//
//   BleManagementBloc({
//     required this.scanDevicesUseCase,
//     required this.connectDeviceUseCase,
//     required this.disconnectDeviceUseCase,
//     required this.discoverServicesUseCase,
//     required this.checkConnectionStatusUseCase,
//   }) : super(BleManagementInitial()) {
//     on<StartScanEvent>(_onStartScan);
//     on<StopScanEvent>(_onStopScan);
//     on<DeviceDiscoveredEvent>(_onDeviceDiscovered);
//     on<ConnectToDeviceEvent>(_onConnectToDevice);
//     on<ConnectionStateChangedEvent>(_onConnectionStateChanged);
//     on<DisconnectEvent>(_onDisconnect);
//     on<CheckConnectionStatusEvent>(_onCheckConnectionStatus);
//     on<BleStatusChangedEvent>(_onBleStatusChanged);
//   }
//
//   Future<void> _onStartScan(
//       StartScanEvent event,
//       Emitter<BleManagementState> emit,
//       ) async {
//     _discoveredDevices.clear();
//     emit(BleScanningState([]));
//
//     await _scanSubscription?.cancel();
//     _scanSubscription = scanDevicesUseCase.call().listen(
//           (device) => add(DeviceDiscoveredEvent(device)),
//       onError: (error) {
//         add(StopScanEvent());
//         emit(BleErrorState('Scan error: $error'));
//       },
//     );
//
//     // Auto stop scan after 30 seconds
//     _scanTimer?.cancel();
//     _scanTimer = Timer(Duration(seconds: 30), () {
//       add(StopScanEvent());
//     });
//   }
//
//   Future<void> _onStopScan(
//       StopScanEvent event,
//       Emitter<BleManagementState> emit,
//       ) async {
//     await _scanSubscription?.cancel();
//     _scanTimer?.cancel();
//     scanDevicesUseCase.stop();
//     emit(BleDevicesFoundState(List.from(_discoveredDevices)));
//   }
//
//   void _onDeviceDiscovered(
//       DeviceDiscoveredEvent event,
//       Emitter<BleManagementState> emit,
//       ) {
//     final index =
//     _discoveredDevices.indexWhere((d) => d.id == event.device.id);
//     if (index >= 0) {
//       _discoveredDevices[index] = event.device;
//     } else {
//       _discoveredDevices.add(event.device);
//     }
//     emit(BleScanningState(List.from(_discoveredDevices)));
//   }
//
//   Future<void> _onConnectToDevice(
//       ConnectToDeviceEvent event,
//       Emitter<BleManagementState> emit,
//       ) async {
//     emit(BleConnectingState(
//       deviceId: event.deviceId,
//       deviceName: event.deviceName,
//     ));
//
//     _currentDeviceId = event.deviceId;
//     _currentDeviceName = event.deviceName;
//
//     await _connectionSubscription?.cancel();
//     _connectionSubscription = connectDeviceUseCase.call(event.deviceId).listen(
//           (connectionState) =>
//           add(ConnectionStateChangedEvent(connectionState)),
//       onError: (error) {
//         emit(BleConnectionFailedState('Connection failed: $error'));
//       },
//     );
//   }
//
//   Future<void> _onConnectionStateChanged(
//       ConnectionStateChangedEvent event,
//       Emitter<BleManagementState> emit,
//       ) async {
//     if (event.connectionState == DeviceConnectionState.connected) {
//       try {
//         // Discover services after connection
//         if (_currentDeviceId != null) {
//           await discoverServicesUseCase.call(_currentDeviceId!);
//           emit(BleConnectedState(
//             deviceId: _currentDeviceId!,
//             deviceName: _currentDeviceName ?? _currentDeviceId!,
//           ));
//         }
//       } catch (e) {
//         emit(BleConnectionFailedState('Service discovery failed: $e'));
//       }
//     } else if (event.connectionState == DeviceConnectionState.disconnected) {
//       emit(BleDisconnectedState());
//       _currentDeviceId = null;
//       _currentDeviceName = null;
//     }
//   }
//
//   Future<void> _onDisconnect(
//       DisconnectEvent event,
//       Emitter<BleManagementState> emit,
//       ) async {
//     try {
//       await disconnectDeviceUseCase.call();
//       await _connectionSubscription?.cancel();
//       _currentDeviceId = null;
//       _currentDeviceName = null;
//       emit(BleDisconnectedState());
//     } catch (e) {
//       emit(BleErrorState('Disconnect failed: $e'));
//     }
//   }
//
//   void _onCheckConnectionStatus(
//       CheckConnectionStatusEvent event,
//       Emitter<BleManagementState> emit,
//       ) {
//     final isConnected = checkConnectionStatusUseCase.call();
//     final deviceId = checkConnectionStatusUseCase.getConnectedDeviceId();
//     final deviceName = checkConnectionStatusUseCase.getConnectedDeviceName();
//
//     print("{{{{{{{{{{{");
//     print(isConnected);
//     print(deviceId);
//     print(deviceName);
//     if (isConnected && deviceId != null) {
//       emit(BleConnectedState(
//         deviceId: deviceId,
//         deviceName: deviceName ?? deviceId,
//       ));
//     } else {
//       emit(BleDisconnectedState());
//     }
//   }
//
//   void _onBleStatusChanged(
//       BleStatusChangedEvent event,
//       Emitter<BleManagementState> emit,
//       ) {
//     if (event.status != BleStatus.ready) {
//       emit(BleNotReadyState(event.status));
//     }
//   }
//
//   @override
//   Future<void> close() {
//     _scanSubscription?.cancel();
//     _connectionSubscription?.cancel();
//     _bleStatusSubscription?.cancel();
//     _scanTimer?.cancel();
//     return super.close();
//   }
// }

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:onegolf/core/utils/wake_lock_helper.dart';
import 'package:onegolf/feature/golf_device/domain/entities/device_entity.dart';
import '../../domain/entities/ble_device_entity.dart';
import '../../domain/usecases/check_connection_status_usecase.dart';
import '../../domain/usecases/connect_device_usecase.dart';
import '../../domain/usecases/disconnect_device_usecase.dart';
import '../../domain/usecases/discover_services_usecase.dart';
import '../../domain/usecases/scan_devices_usecase.dart';
import 'ble_management_event.dart';
import 'ble_management_state.dart';

class BleManagementBloc extends Bloc<BleManagementEvent, BleManagementState> {
  final ScanDevicesUseCase scanDevicesUseCase;
  final ConnectDeviceUseCase connectDeviceUseCase;
  final DisconnectDeviceUseCase disconnectDeviceUseCase;
  final DiscoverServicesUseCase discoverServicesUseCase;
  final CheckConnectionStatusUseCase checkConnectionStatusUseCase;

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _bleStatusSubscription;
  Timer? _scanTimer;

  final List<BleDeviceEntity> _discoveredDevices = [];
  String? _currentDeviceId;
  String? _currentDeviceName;

  BleManagementBloc({
    required this.scanDevicesUseCase,
    required this.connectDeviceUseCase,
    required this.disconnectDeviceUseCase,
    required this.discoverServicesUseCase,
    required this.checkConnectionStatusUseCase,
  }) : super(BleManagementInitial()) {
    on<StartScanEvent>(_onStartScan);
    on<StopScanEvent>(_onStopScan);
    on<DeviceDiscoveredEvent>(_onDeviceDiscovered);
    on<ConnectToDeviceEvent>(_onConnectToDevice);
    on<ConnectionStateChangedEvent>(_onConnectionStateChanged);
    on<DisconnectEvent>(_onDisconnect);
    on<CheckConnectionStatusEvent>(_onCheckConnectionStatus);
    on<BleStatusChangedEvent>(_onBleStatusChanged);
  }

  Future<void> _onStartScan(
      StartScanEvent event,
      Emitter<BleManagementState> emit,
      ) async {
    print('🔍 Starting BLE scan...');
    _discoveredDevices.clear();
    emit(BleScanningState([]));

    await _scanSubscription?.cancel();
    _scanSubscription = scanDevicesUseCase.call().listen(
          (device) {
        print('📱 Device discovered: ${device.name}');
        add(DeviceDiscoveredEvent(device));
      },
      onError: (error) {
        print('❌ Scan error: $error');
        add(StopScanEvent());
        emit(BleErrorState('Scan error: $error'));
      },
    );

    // Auto stop scan after 30 seconds
    _scanTimer?.cancel();
    _scanTimer = Timer(Duration(seconds: 3), () {
      print('⏱️ Scan timeout - stopping scan');
      add(StopScanEvent());
    });
  }

  Future<void> _onStopScan(
      StopScanEvent event,
      Emitter<BleManagementState> emit,
      ) async {
    print('🛑 Stopping scan...');
    await _scanSubscription?.cancel();
    _scanTimer?.cancel();
    scanDevicesUseCase.stop();
    emit(BleDevicesFoundState(List.from(_discoveredDevices)));
    print('✅ Scan stopped. Found ${_discoveredDevices.length} devices');
  }

  void _onDeviceDiscovered(
      DeviceDiscoveredEvent event,
      Emitter<BleManagementState> emit,
      ) {
    final index =
    _discoveredDevices.indexWhere((d) => d.id == event.device.id);
    if (index >= 0) {
      _discoveredDevices[index] = event.device;
    } else {
      _discoveredDevices.add(event.device);
    }
    emit(BleScanningState(List.from(_discoveredDevices)));
  }

  Future<void> _onConnectToDevice(
      ConnectToDeviceEvent event,
      Emitter<BleManagementState> emit,
      ) async {
    emit(BleConnectingState(
      deviceId: event.deviceId,
      deviceName: event.deviceName,
    ));

    _currentDeviceId = event.deviceId;
    _currentDeviceName = event.deviceName;

    await _connectionSubscription?.cancel();
    _connectionSubscription = connectDeviceUseCase.call(event.deviceId).listen(
          (connectionState) {
        add(ConnectionStateChangedEvent(connectionState));
      },
      onError: (error) {
        print('❌ Connection error: $error');
        emit(BleConnectionFailedState('Connection failed: $error'));
      },
    );
  }

  Future<void> _onConnectionStateChanged(
      ConnectionStateChangedEvent event,
      Emitter<BleManagementState> emit,
      ) async {
    print('🔵 Processing connection state: ${event.connectionState}');

    if (event.connectionState == DeviceConnectionState.connected) {
      print('✅ Device connected! Discovering services...');
      await WakeLockHelper.enable();

      try {
        // Discover services after connection
        if (_currentDeviceId != null) {
          await discoverServicesUseCase.call(_currentDeviceId!);

          print('✅ Services discovered successfully!');
          print('   Device ID: $_currentDeviceId');
          print('   Device Name: $_currentDeviceName');

          emit(BleConnectedState(
            deviceId: _currentDeviceId!,
            deviceName: _currentDeviceName ?? _currentDeviceId!,
          ));
        } else {
          print('❌ Error: Device ID is null!');
          emit(BleConnectionFailedState('Device ID is null'));
        }
      } catch (e) {
        print('❌ Service discovery failed: $e');
        emit(BleConnectionFailedState('Service discovery failed: $e'));
      }
    } else if (event.connectionState == DeviceConnectionState.disconnected) {
      print('🔴 Device disconnected');
      await WakeLockHelper.disable();
      emit(BleDisconnectedState());
      _currentDeviceId = null;
      _currentDeviceName = null;
    }
  }

  Future<void> _onDisconnect(
      DisconnectEvent event,
      Emitter<BleManagementState> emit,
      ) async {
    print('🔴 BLoC: Disconnecting device...');
    await WakeLockHelper.disable();

    try {
      await disconnectDeviceUseCase.call();
      await _connectionSubscription?.cancel();
      _currentDeviceId = null;
      _currentDeviceName = null;
      emit(BleDisconnectedState());

      print('✅ Disconnected successfully');
    } catch (e) {
      print('❌ Disconnect failed: $e');
      emit(BleErrorState('Disconnect failed: $e'));
    }
  }

  void _onCheckConnectionStatus(
      CheckConnectionStatusEvent event,
      Emitter<BleManagementState> emit,
      ) {
    print('🔍 Checking connection status...');

    final isConnected = checkConnectionStatusUseCase.call();
    final deviceId = checkConnectionStatusUseCase.getConnectedDeviceId();
    final deviceName = checkConnectionStatusUseCase.getConnectedDeviceName();

    print('   Is Connected: $isConnected');
    print('   Device ID: $deviceId');
    print('   Device Name: $deviceName');

    if (isConnected && deviceId != null) {
      // Update current device info from use case
      _currentDeviceId = deviceId;
      _currentDeviceName = deviceName;

      emit(BleConnectedState(
        deviceId: deviceId,
        deviceName: deviceName ?? deviceId,
      ));
      print('✅ Device is connected');
    } else {
      emit(BleDisconnectedState());
      print('❌ Device is not connected');
    }
  }

  void _onBleStatusChanged(
      BleStatusChangedEvent event,
      Emitter<BleManagementState> emit,
      ) {
    print('📡 BLE status changed: ${event.status}');

    if (event.status != BleStatus.ready) {
      emit(BleNotReadyState(event.status));
    }
  }

  @override
  Future<void> close() async {
    await WakeLockHelper.disable();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _bleStatusSubscription?.cancel();
    _scanTimer?.cancel();
    return super.close();
  }
}