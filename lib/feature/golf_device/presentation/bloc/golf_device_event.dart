import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../domain/entities/device_entity.dart';
import 'golf_device_state.dart';

abstract class GolfDeviceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectToDeviceEvent extends GolfDeviceEvent {
  final DeviceEntity device;

  ConnectToDeviceEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class ConnectionStateChangedEvent extends GolfDeviceEvent {
  final bool isConnected;

  ConnectionStateChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
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

class DisconnectDeviceEvent extends GolfDeviceEvent {
  final bool isNotBottom;

  DisconnectDeviceEvent({this.isNotBottom = true});

  @override
  List<Object?> get props => [isNotBottom];
}

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

class ResetGolfDeviceEvent extends GolfDeviceEvent {
  ResetGolfDeviceEvent();

  @override
  List<Object?> get props => [];
}

class PauseBleSyncEvent extends GolfDeviceEvent {}

class ResumeBleSyncEvent extends GolfDeviceEvent {}

