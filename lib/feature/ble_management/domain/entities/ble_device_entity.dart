import 'package:equatable/equatable.dart';
class BleDeviceEntity extends Equatable {
  final String id;
  final String name;
  final int rssi;

  const BleDeviceEntity({
    required this.id,
    required this.name,
    required this.rssi,
  });

  @override
  List<Object?> get props => [id, name, rssi];
}