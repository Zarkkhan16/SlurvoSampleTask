import 'package:equatable/equatable.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';
import 'package:Slurvo/feature/home_screens/data/models/shot_data_model.dart';
import 'package:Slurvo/feature/home_screens/domain/entities/shot_data.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_service.dart'; // correct

abstract class BleState extends Equatable {
  const BleState();

  @override
  List<Object?> get props => [];
}

class BleInitial extends BleState {}

class BleScanning extends BleState {}

class BleDevicesFound extends BleState {
  final List<BleDevice> devices;

  const BleDevicesFound({required this.devices});

  @override
  List<Object> get props => [devices];
}

class BleConnecting extends BleState {}

class BleConnected extends BleState {
  final BleDevice device;
  final List<BleService> services;

  const BleConnected({required this.device, required this.services});

  @override
  List<Object> get props => [device, services];
}

class BleScannedDevices extends BleState {
  final List<BleDevice> scannedDevice;

  const BleScannedDevices({
    required this.scannedDevice,
  });

  @override
  List<Object> get props => [
        scannedDevice,
      ];
}

class BleDisconnected extends BleState {}

class BleCharacteristicRead extends BleState {
  final List<int> data;

  const BleCharacteristicRead({required this.data});

  @override
  List<Object> get props => [data];
}

class BleCharacteristicWritten extends BleState {}

class BleMockDataFound extends BleState {
  final List<ShotData> mockData;

  const BleMockDataFound({required this.mockData});

  @override
  List<Object> get props => [mockData];
}

class BleLoaded extends BleState {
  final bool isConnected;
  final List<ShotData> shotData;

  const BleLoaded({required this.isConnected, required this.shotData});

  @override
  List<Object> get props => [isConnected, shotData];
}

class BleError extends BleState {
  final String message;

  const BleError({required this.message});

  @override
  List<Object> get props => [message];
}
