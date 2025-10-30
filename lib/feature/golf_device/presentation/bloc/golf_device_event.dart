import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../domain/entities/device_entity.dart';
import 'golf_device_state.dart';

abstract class GolfDeviceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartScanningEvent extends GolfDeviceEvent {}

class StopScanningEvent extends GolfDeviceEvent {}

class DeviceDiscoveredEvent extends GolfDeviceEvent {
  final DeviceEntity device;

  DeviceDiscoveredEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class ConnectToDeviceEvent extends GolfDeviceEvent {
  final DeviceEntity device;

  ConnectToDeviceEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class ConnectionStateChangedEvent extends GolfDeviceEvent {
  final DeviceConnectionState state;

  ConnectionStateChangedEvent(this.state);

  @override
  List<Object?> get props => [state];
}

class NotificationReceivedEvent extends GolfDeviceEvent {
  final List<int> data;

  NotificationReceivedEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class SendSyncPacketEvent extends GolfDeviceEvent {}

class UpdateClubEvent extends GolfDeviceEvent {
  final int clubId;

  UpdateClubEvent(this.clubId);

  @override
  List<Object?> get props => [clubId];
}

class ToggleUnitsEvent extends GolfDeviceEvent {}

class DisconnectDeviceEvent extends GolfDeviceEvent {}

class UpdateElapsedTimeEvent extends GolfDeviceEvent {}

class LoadShotRecordsEvent extends GolfDeviceEvent {}

class SaveAllShotsEvent extends GolfDeviceEvent {}

class ReturnToConnectedStateEvent extends GolfDeviceEvent {
  ReturnToConnectedStateEvent();

  @override
  List<Object?> get props => [];
}

class DeleteLatestShotEvent extends GolfDeviceEvent {}

class UpdateMetricFilterEvent extends GolfDeviceEvent {
  final Set<String> selectedMetrics;

  UpdateMetricFilterEvent(this.selectedMetrics);

  @override
  List<Object?> get props => [selectedMetrics];
}
