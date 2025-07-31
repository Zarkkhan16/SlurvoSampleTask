import 'package:equatable/equatable.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';

abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object?> get props => [];
}

class StartScanEvent extends BleEvent {}

class StopScanEvent extends BleEvent {}

class ConnectToDeviceEvent extends BleEvent {
  final String deviceId;

  const ConnectToDeviceEvent(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class DisconnectDeviceEvent extends BleEvent {
  final String deviceId;

  const DisconnectDeviceEvent(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

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

class DevicesDiscovered extends BleEvent {
  final List<BleDevice> devices;

  const DevicesDiscovered(this.devices);

  @override
  List<Object> get props => [devices];
}

class ShowMockDataEvent extends BleEvent {}
