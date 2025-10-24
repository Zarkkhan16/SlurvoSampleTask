import 'package:equatable/equatable.dart';
import '../../data/model/shot_anaylsis_model.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/golf_data_entities.dart';

abstract class GolfDeviceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GolfDeviceInitial extends GolfDeviceState {}

class ScanningState extends GolfDeviceState {
  final List<DeviceEntity> devices;

  ScanningState(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DevicesFoundState extends GolfDeviceState {
  final List<DeviceEntity> devices;

  DevicesFoundState(this.devices);

  @override
  List<Object?> get props => [devices];
}

class ConnectingState extends GolfDeviceState {
  final List<DeviceEntity> devices;

  ConnectingState(this.devices);

  @override
  List<Object?> get props => [devices];
}

class ConnectedState extends GolfDeviceState {
  final DeviceEntity device;
  final GolfDataEntity golfData;
  final bool isLoading;
  final bool units;
  final String currentDate;
  final String elapsedTime;
  final Set<String> selectedMetrics;

  ConnectedState({
    required this.device,
    required this.golfData,
    this.isLoading = false,
    this.units = false,
    this.currentDate = '',
    this.elapsedTime = '00:00:00',
    Set<String>? selectedMetrics,
  }) : selectedMetrics = selectedMetrics ?? {
    'Club Speed',
    'Ball Speed',
    'Carry Distance',
    'Total Distance',
    'Smash Factor',
  };

  ConnectedState copyWith({
    DeviceEntity? device,
    GolfDataEntity? golfData,
    bool? isLoading,
    bool? units,
    String? currentDate,
    String? elapsedTime,
    Set<String>? selectedMetrics,
  }) {
    return ConnectedState(
      device: device ?? this.device,
      golfData: golfData ?? this.golfData,
      isLoading: isLoading ?? this.isLoading,
      units: units ?? this.units,
      currentDate: currentDate ?? this.currentDate,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      selectedMetrics: selectedMetrics ?? this.selectedMetrics,
    );
  }

  @override
  List<Object?> get props => [device, golfData, isLoading, units, currentDate, elapsedTime,selectedMetrics,];
}

class DisconnectedState extends GolfDeviceState {
  final List<DeviceEntity> devices;

  DisconnectedState(this.devices);

  @override
  List<Object?> get props => [devices];
}

class ClubUpdatedState extends ConnectedState {
  ClubUpdatedState({
    required DeviceEntity device,
    required GolfDataEntity golfData,
    required bool units,
    Set<String>? selectedMetrics,
  }) : super(device: device, golfData: golfData, isLoading: false, units: units, selectedMetrics: selectedMetrics,);
}

class ErrorState extends GolfDeviceState {
  final String message;

  ErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class NavigateToLandDashboardState extends GolfDeviceState {}

class SaveShots extends GolfDeviceState {}

class ShotRecordsLoadedState extends GolfDeviceState {
  final List<Map<String, dynamic>> shotRecords;

  ShotRecordsLoadedState(this.shotRecords);
}
class ShotHistoryLoadingState extends GolfDeviceState {}
class ShotHistoryLoadedState extends GolfDeviceState {
  final List<ShotAnalysisModel> shots;
  ShotHistoryLoadedState(this.shots);
}

class ShotHistoryErrorState extends GolfDeviceState {
  final String message;
  ShotHistoryErrorState(this.message);
}

class DisconnectingState extends GolfDeviceState {}
class SaveShotsSuccessfully extends GolfDeviceState {}
class SaveDataLoading extends GolfDeviceState {}