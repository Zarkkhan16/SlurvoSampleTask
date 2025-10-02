import 'package:equatable/equatable.dart';
import 'package:OneGolf/feature/ble/domain/entities/ble_device.dart';
import 'package:OneGolf/feature/ble/domain/entities/ble_service.dart';
import 'package:OneGolf/feature/home_screens/domain/entities/shot_data.dart';

abstract class BleState extends Equatable {
  const BleState();

  @override
  List<Object?> get props => [];
}

// --- Initial / Scanning ---
class BleInitial extends BleState {}
class BleScanning extends BleState {}

// --- Devices ---
class BleScannedDevices extends BleState {
  final List<BleDevice> scannedDevice;
  const BleScannedDevices({required this.scannedDevice});

  @override
  List<Object> get props => [scannedDevice];
}

// --- Connection ---
class BleConnecting extends BleState {
  final String? deviceName;
  const BleConnecting({this.deviceName});

  @override
  List<Object?> get props => [deviceName];
}

class BleConnected extends BleState {
  final BleDevice device;
  final List<BleService> services;
  const BleConnected({required this.device, required this.services});

  @override
  List<Object> get props => [device, services];
}

class BleDisconnected extends BleState {}

// --- Characteristics ---
class BleCharacteristicRead extends BleState {
  final List<int> data;
  const BleCharacteristicRead({required this.data});

  @override
  List<Object> get props => [data];
}

class BleCharacteristicWritten extends BleState {}

// --- Mock Data ---
class BleMockDataFound extends BleState {
  final List<ShotData> mockData;
  const BleMockDataFound({required this.mockData});

  @override
  List<Object> get props => [mockData];
}

// --- Errors ---
class BleError extends BleState {
  final String message;
  const BleError({required this.message});

  @override
  List<Object> get props => [message];
}

// --- Pairing ---
class BlePairingRequested extends BleState {
  final String deviceId;
  final String deviceName;
  const BlePairingRequested({required this.deviceId, required this.deviceName});

  @override
  List<Object> get props => [deviceId, deviceName];
}

class BleShotData extends BleState {
  final List<ShotDataNew> shots;
  BleShotData(this.shots);
}