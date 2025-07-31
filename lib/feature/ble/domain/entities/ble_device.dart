import 'package:equatable/equatable.dart';

class BleDevice extends Equatable {
  final String id;
  final String name;
  final String type;
  final int rssi;
  final bool isConnected;

  const BleDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.rssi,
    this.isConnected = false,
  });

  @override
  List<Object?> get props => [id, name, type, rssi, isConnected];
}