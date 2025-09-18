import 'package:equatable/equatable.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object?> get props => [];
}

// --- Scanning ---
class StartScanEvent extends BleEvent {}
class StopScanEvent extends BleEvent {}
class ScannedDevicesEvent extends BleEvent {
  final List<BleDevice> targetDevice;
  const ScannedDevicesEvent(this.targetDevice);

  @override
  List<Object> get props => [targetDevice];
}

// --- Device connection ---
class ConnectToDeviceEvent extends BleEvent {
  final String deviceId;
  final String? deviceName; // Optional parameter
  const ConnectToDeviceEvent(this.deviceId, {this.deviceName});

  @override
  List<Object?> get props => [deviceId, deviceName];
}

class DisconnectDeviceEvent extends BleEvent {
  final String deviceId;
  const DisconnectDeviceEvent(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class ConnectionStateEvent extends BleEvent {
  final String deviceId;
  final DeviceConnectionState connectionState;
  const ConnectionStateEvent(this.deviceId, this.connectionState);

  @override
  List<Object> get props => [deviceId, connectionState];
}

class ConnectionTimeoutEvent extends BleEvent {
  final String deviceId;
  final String? error;
  const ConnectionTimeoutEvent(this.deviceId, {this.error});

  @override
  List<Object?> get props => [deviceId, error];
}

// --- Characteristics ---
class ReadCharacteristicEvent extends BleEvent {
  final String deviceId;
  final String serviceUuid;
  final String characteristicUuid;

  const ReadCharacteristicEvent({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
  });

  @override
  List<Object> get props => [deviceId, serviceUuid, characteristicUuid];
}

class WriteCharacteristicEvent extends BleEvent {
  final String deviceId;
  final String serviceUuid;
  final String characteristicUuid;
  final List<int> data;

  const WriteCharacteristicEvent({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.data,
  });

  @override
  List<Object> get props => [deviceId, serviceUuid, characteristicUuid, data];
}

// --- Mock data ---
class ShowMockDataEvent extends BleEvent {}

// --- Pairing ---
class RequestPairingEvent extends BleEvent {
  final String deviceId;
  final String deviceName;
  const RequestPairingEvent(this.deviceId, this.deviceName);

  @override
  List<Object> get props => [deviceId, deviceName];
}
