import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sample_task/core/constants/app_constants.dart';
import 'package:sample_task/core/usecases/usecase.dart';
import 'package:sample_task/feature/ble/domain/entities/ble_device.dart';
import 'package:sample_task/feature/ble/domain/usecases/connect_to_device.dart';
import 'package:sample_task/feature/ble/domain/usecases/discover_devices.dart';
import 'package:sample_task/feature/ble/domain/usecases/read_characteristic.dart';
import 'package:sample_task/feature/ble/domain/usecases/scan_for_devices.dart';
import 'package:sample_task/feature/ble/domain/usecases/write_characteristics.dart';
import 'package:sample_task/feature/ble/presentation/block/ble_event.dart';
import 'package:sample_task/feature/ble/presentation/block/ble_state.dart';
import 'package:sample_task/feature/home_screens/domain/repositories/shot_repository.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  final ScanForDevices scanForDevices;
  final ConnectToDevice connectToDevice;
  final DiscoverServices discoverServices;
  final ReadCharacteristic readCharacteristic;
  final WriteCharacteristic writeCharacteristic;
  final ShotRepository shotRepository;

  StreamSubscription<List<BleDevice>>? _scanSubscription;

  BleBloc({
    required this.scanForDevices,
    required this.connectToDevice,
    required this.discoverServices,
    required this.readCharacteristic,
    required this.writeCharacteristic,
    required this.shotRepository,
  }) : super(BleInitial()) {
    on<StartScanEvent>(_onStartScan);
    on<StopScanEvent>(_onStopScan);
    on<ConnectToDeviceEvent>(_onConnectToDevice);
    on<DisconnectDeviceEvent>(_onDisconnectDevice);
    on<ReadCharacteristicEvent>(_onReadCharacteristic);
    on<WriteCharacteristicEvent>(_onWriteCharacteristic);
    on<ShowMockDataEvent>(_onShowMockData);
    on<DevicesDiscovered>(_onDevicesDiscovered);
  }
  void _onStartScan(StartScanEvent event, Emitter<BleState> emit) async {
    emit(BleScanning());

    _scanSubscription?.cancel();

    final List<BleDevice> scannedDevices = [];

    _scanSubscription = scanForDevices(NoParams()).listen(
          (devices) {
        scannedDevices.clear();
        scannedDevices.addAll(devices);
        add(DevicesDiscovered(devices));
      },
      onError: (error) {
        emit(BleError(message: error.toString()));
      },
    );

    // Waiting for 3 seconds before checking
    await Future.delayed(const Duration(seconds: 3));
    final matchingDevices = scannedDevices.where(
          (device) => device.id.toUpperCase() == AppConstants.bleId,
    );

    BleDevice? targetDevice = matchingDevices.isNotEmpty ? matchingDevices.first : null;


    if (targetDevice != null) {
      add(ConnectToDeviceEvent(targetDevice.id));
    } else {
      _scanSubscription?.cancel();
      emit(BleInitial());
      add(ShowMockDataEvent());
    }
  }

  void _onStopScan(StopScanEvent event, Emitter<BleState> emit) {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(BleInitial());
  }

  Future<void> _onConnectToDevice(
    ConnectToDeviceEvent event,
    Emitter<BleState> emit,
  ) async {
    emit(BleConnecting());

    final connected =
        await connectToDevice(ConnectToDeviceParams(deviceId: event.deviceId));

    if (!connected) {
      emit(BleError(message: "Failed to connect to device"));
      return;
    }

    final services = await discoverServices(
        DiscoverServicesParams(deviceId: event.deviceId));

    if (services == null) {
      emit(BleError(message: "Failed to discover services"));
      return;
    }

    final device = BleDevice(
      id: event.deviceId,
      name: 'Connected Device',
      type: 'BLE',
      rssi: 0,
      isConnected: true,
    );

    emit(BleConnected(device: device, services: services));
  }

  Future<void> _onDisconnectDevice(
    DisconnectDeviceEvent event,
    Emitter<BleState> emit,
  ) async {
    if (event.deviceId.isEmpty) {
      final mockData = await shotRepository.getShotData();
      emit(BleMockDataFound(mockData: mockData));
    }
  }

  Future<void> _onReadCharacteristic(
    ReadCharacteristicEvent event,
    Emitter<BleState> emit,
  ) async {
    final data = await readCharacteristic(ReadCharacteristicParams(
      deviceId: event.deviceId,
      serviceUuid: event.serviceUuid,
      characteristicUuid: event.characteristicUuid,
    ));

    if (data == null) {
      emit(BleError(message: "Failed to read characteristic"));
      return;
    }

    emit(BleCharacteristicRead(data: data));
  }

  Future<void> _onWriteCharacteristic(
    WriteCharacteristicEvent event,
    Emitter<BleState> emit,
  ) async {
    final success = await writeCharacteristic(WriteCharacteristicParams(
      deviceId: event.deviceId,
      serviceUuid: event.serviceUuid,
      characteristicUuid: event.characteristicUuid,
      data: event.data,
    ));

    if (success) {
      emit(BleCharacteristicWritten());
    } else {
      emit(BleError(message: "Failed to write characteristic"));
    }
  }

  void _onDevicesDiscovered(
    DevicesDiscovered event,
    Emitter<BleState> emit,
  ) {
    emit(BleDevicesFound(devices: event.devices));
  }

  Future<void> _onShowMockData(
      ShowMockDataEvent event, Emitter<BleState> emit) async {
    try {
      final mockData = await shotRepository.getShotData();
      emit(BleMockDataFound(mockData: mockData));
    } catch (e) {
      emit(BleError(message: "Failed to Get Data"));
    }
  }

  @override
  Future<void> close() async {
    await _scanSubscription?.cancel();
    return super.close();
  }
}
