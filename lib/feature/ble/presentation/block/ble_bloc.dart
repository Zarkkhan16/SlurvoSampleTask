import 'dart:async';
import 'package:Slurvo/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_service.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_characteristic.dart';
import 'package:Slurvo/feature/home_screens/domain/repositories/shot_repository.dart';
import 'ble_event.dart';
import 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  final FlutterReactiveBle _ble;
  final ShotRepository shotRepository;

  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  Timer? _connectionTimer;
  String? _currentConnectingDeviceId;
  String? _currentConnectingDeviceName;

  BleBloc({required FlutterReactiveBle ble, required this.shotRepository})
      : _ble = ble,
        super(BleInitial()) {
    on<StartScanEvent>(_onStartScan);
    on<StopScanEvent>(_onStopScan);
    on<ConnectToDeviceEvent>(_onConnectToDevice);
    on<DisconnectDeviceEvent>(_onDisconnectDevice);
    on<ReadCharacteristicEvent>(_onReadCharacteristic);
    on<WriteCharacteristicEvent>(_onWriteCharacteristic);
    on<ScannedDevicesEvent>(_onScannedDevices);
    on<ShowMockDataEvent>(_onShowMockData);
    on<ConnectionTimeoutEvent>(_onConnectionTimeout);
    on<ConnectionStateEvent>(_onConnectionState);
    on<RequestPairingEvent>(_onRequestPairing);
  }


  Future<void> _onStartScan(StartScanEvent event, Emitter<BleState> emit) async {
    _cancelConnectionAttempt();
    emit(BleScanning());

    _scanSubscription?.cancel();
    final scannedDevices = <BleDevice>[];

    _scanSubscription = _ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
        .listen((device) {
      final bleDevice = BleDevice(
        id: device.id,
        name: device.name.isNotEmpty ? device.name : "Unknown Device",
        type: "BLE",
        rssi: device.rssi,
        isConnected: false,
      );

      scannedDevices.removeWhere((d) => d.id == bleDevice.id);
      scannedDevices.add(bleDevice);
      scannedDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

      // Filter for specific device after each scan
      final matchingDevices = scannedDevices.where((d) =>
      d.id == AppConstants.bleId ||
          d.name.contains(AppConstants.bleName)
      ).toList();

      if (!isClosed) add(ScannedDevicesEvent(matchingDevices));
    }, onError: (error) {
      if (!isClosed) emit(BleError(message: "Scanning failed: $error"));
    });

    // Stop scanning after 30 seconds
    Timer(const Duration(seconds: 30), () {
      if (!isClosed) {
        _scanSubscription?.cancel();

        final matchingDevices = scannedDevices.where((d) =>
        d.id == AppConstants.bleId ||
            d.name.contains(AppConstants.bleName)
        ).toList();

        if (matchingDevices.isEmpty && state is BleScanning) {
          emit(BleError(message: "No matching devices found. Ensure your device is nearby and discoverable."));
        }
      }
    });
  }

  void _onStopScan(StopScanEvent event, Emitter<BleState> emit) {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(BleInitial());
  }

  Future<void> _onConnectToDevice(ConnectToDeviceEvent event, Emitter<BleState> emit) async {
    _scanSubscription?.cancel();
    _cancelConnectionAttempt();

    _currentConnectingDeviceId = event.deviceId;
    _currentConnectingDeviceName = event.deviceName;
    emit(BleConnecting(deviceName: event.deviceName ?? "Unknown Device"));

    _connectionTimer = Timer(const Duration(seconds: 10), () {
      if (!isClosed && _currentConnectingDeviceId == event.deviceId) {
        add(ConnectionTimeoutEvent(event.deviceId));
      }
    });

    try {
      _connectionSubscription = _ble.connectToDevice(id: event.deviceId, connectionTimeout: const Duration(seconds: 8))
          .listen((update) {
        if (!isClosed) add(ConnectionStateEvent(event.deviceId, update.connectionState));
      }, onError: (error) {
        _connectionTimer?.cancel();
        if (!isClosed) add(ConnectionTimeoutEvent(event.deviceId, error: error.toString()));
      }, onDone: () => _connectionTimer?.cancel());
    } catch (e) {
      _connectionTimer?.cancel();
      if (!isClosed) emit(BleError(message: "Failed to start connection: $e"));
    }
  }

  Future<void> _onConnectionState(ConnectionStateEvent event, Emitter<BleState> emit) async {
    switch (event.connectionState) {
      case DeviceConnectionState.connected:
        _connectionTimer?.cancel();
        try {
          print(event.deviceId);
          print(event.deviceId);
          await Future.delayed(Duration(milliseconds: 500));

          final services = await _ble.discoverServices(event.deviceId);
          print(services);
          print('[][[][][][');
          final bleServices = services.map((s) => BleService(
            uuid: s.serviceId.toString(),
            characteristics: s.characteristics.map((c) => BleCharacteristic(
              uuid: c.characteristicId.toString(),
              canRead: c.isReadable,
              canWrite: c.isWritableWithResponse || c.isWritableWithoutResponse,
              canNotify: c.isNotifiable,
              value: null,
            )).toList(),
          )).toList();

          emit(BleConnected(
            device: BleDevice(
              id: event.deviceId,
              name: _currentConnectingDeviceName ?? "Connected Device",
              type: "BLE",
              rssi: 0,
              isConnected: true,
            ),
            services: bleServices,
          ));
          break;

        } catch (e) {
          print(e);
          emit(BleError(message: "Failed to discover services: $e"));
        }
        break;

      case DeviceConnectionState.disconnected:
        _connectionTimer?.cancel();
        emit(_currentConnectingDeviceId == event.deviceId ? BleError(message: "Device disconnected unexpectedly") : BleDisconnected());
        break;

      default:
        break;
    }
  }

  void _cancelConnectionAttempt() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _currentConnectingDeviceId = null;
    _currentConnectingDeviceName = null;
  }

  Future<void> _onDisconnectDevice(DisconnectDeviceEvent event, Emitter<BleState> emit) async {
    _cancelConnectionAttempt();
    emit(BleDisconnected());
  }

  Future<void> _onReadCharacteristic(ReadCharacteristicEvent event, Emitter<BleState> emit) async {
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(event.serviceUuid),
        characteristicId: Uuid.parse(event.characteristicUuid),
        deviceId: event.deviceId,
      );
      final value = await _ble.readCharacteristic(characteristic);
      emit(BleCharacteristicRead(data: value));
    } catch (e) {
      emit(BleError(message: "Failed to read characteristic: $e"));
    }
  }

  Future<void> _onWriteCharacteristic(WriteCharacteristicEvent event, Emitter<BleState> emit) async {
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(event.serviceUuid),
        characteristicId: Uuid.parse(event.characteristicUuid),
        deviceId: event.deviceId,
      );
      await _ble.writeCharacteristicWithResponse(characteristic, value: event.data);
      emit(BleCharacteristicWritten());
    } catch (e) {
      emit(BleError(message: "Failed to write characteristic: $e"));
    }
  }

  void _onScannedDevices(ScannedDevicesEvent event, Emitter<BleState> emit) {
    emit(BleScannedDevices(scannedDevice: event.targetDevice));
  }

  Future<void> _onShowMockData(ShowMockDataEvent event, Emitter<BleState> emit) async {
    try {
      final mockData = await shotRepository.getShotData();
      emit(BleMockDataFound(mockData: mockData));
    } catch (e) {
      emit(BleError(message: "Failed to get mock data: $e"));
    }
  }

  void _onConnectionTimeout(ConnectionTimeoutEvent event, Emitter<BleState> emit) {
    _cancelConnectionAttempt();
    emit(BleError(message: event.error != null ? "Connection failed: ${event.error}" : "Connection timeout. Please try again."));
  }

  Future<void> _onRequestPairing(RequestPairingEvent event, Emitter<BleState> emit) async {
    emit(BlePairingRequested(deviceId: event.deviceId, deviceName: event.deviceName));
  }

  @override
  Future<void> close() async {
    _cancelConnectionAttempt();
    await _scanSubscription?.cancel();
    return super.close();
  }
}
