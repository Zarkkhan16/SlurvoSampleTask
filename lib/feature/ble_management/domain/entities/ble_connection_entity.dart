import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleConnectionEntity extends Equatable {
  final String? deviceId;
  final String? deviceName;
  final DeviceConnectionState connectionState;
  final bool isConnected;
  final int? batteryLevel;

  const BleConnectionEntity({
    this.deviceId,
    this.deviceName,
    required this.connectionState,
    required this.isConnected,
    this.batteryLevel,
  });

  BleConnectionEntity copyWith({
    String? deviceId,
    String? deviceName,
    DeviceConnectionState? connectionState,
    bool? isConnected,
    int? batteryLevel,
  }) {
    return BleConnectionEntity(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      connectionState: connectionState ?? this.connectionState,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }

  @override
  List<Object?> get props => [
    deviceId,
    deviceName,
    connectionState,
    isConnected,
    batteryLevel,
  ];
}