import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../../golf_device/domain/entities/device_entity.dart';
import '../../domain/entities/ble_device_entity.dart';

abstract class BleManagementEvent extends Equatable {
  const BleManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Start scanning for devices
class StartScanEvent extends BleManagementEvent {}

/// Stop scanning for devices
class StopScanEvent extends BleManagementEvent {}

/// Device discovered during scan
class DeviceDiscoveredEvent extends BleManagementEvent {
  final BleDeviceEntity device;

  const DeviceDiscoveredEvent(this.device);

  @override
  List<Object?> get props => [device];
}

/// Connect to a specific device
class ConnectToDeviceEvent extends BleManagementEvent {
  final String deviceId;
  final String deviceName;

  const ConnectToDeviceEvent({
    required this.deviceId,
    required this.deviceName,
  });

  @override
  List<Object?> get props => [deviceId, deviceName];
}

/// Connection state changed
class ConnectionStateChangedEvent extends BleManagementEvent {
  final DeviceConnectionState connectionState;

  const ConnectionStateChangedEvent(this.connectionState);

  @override
  List<Object?> get props => [connectionState];
}

/// Disconnect from device
class DisconnectEvent extends BleManagementEvent {}

/// Check current connection status
class CheckConnectionStatusEvent extends BleManagementEvent {}

/// BLE status changed
class BleStatusChangedEvent extends BleManagementEvent {
  final BleStatus status;

  const BleStatusChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}