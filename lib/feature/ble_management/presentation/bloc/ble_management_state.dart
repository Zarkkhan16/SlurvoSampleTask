import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../../golf_device/domain/entities/device_entity.dart';
import '../../domain/entities/ble_device_entity.dart';

abstract class BleManagementState extends Equatable {
  const BleManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BleManagementInitial extends BleManagementState {}

/// BLE is not ready (turned off or unauthorized)
class BleNotReadyState extends BleManagementState {
  final BleStatus status;

  const BleNotReadyState(this.status);

  @override
  List<Object?> get props => [status];
}

/// Scanning for devices
class BleScanningState extends BleManagementState {
  final List<BleDeviceEntity> devices;

  const BleScanningState(this.devices);

  @override
  List<Object?> get props => [devices];
}

/// Devices found (scan complete)
class BleDevicesFoundState extends BleManagementState {
  final List<BleDeviceEntity> devices;

  const BleDevicesFoundState(this.devices);

  @override
  List<Object?> get props => [devices];
}

/// Connecting to device
class BleConnectingState extends BleManagementState {
  final String deviceId;
  final String deviceName;

  const BleConnectingState({
    required this.deviceId,
    required this.deviceName,
  });

  @override
  List<Object?> get props => [deviceId, deviceName];
}

/// Connected to device
class BleConnectedState extends BleManagementState {
  final String deviceId;
  final String deviceName;

  const BleConnectedState({
    required this.deviceId,
    required this.deviceName,
  });

  @override
  List<Object?> get props => [deviceId, deviceName];
}

/// Disconnected from device
class BleDisconnectedState extends BleManagementState {}

/// Connection failed
class BleConnectionFailedState extends BleManagementState {
  final String message;

  const BleConnectionFailedState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class BleErrorState extends BleManagementState {
  final String message;

  const BleErrorState(this.message);

  @override
  List<Object?> get props => [message];
}