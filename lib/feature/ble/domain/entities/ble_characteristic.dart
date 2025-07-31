import 'package:equatable/equatable.dart';

class BleCharacteristic extends Equatable {
  final String uuid;
  final bool canRead;
  final bool canWrite;
  final bool canNotify;
  final List<int>? value;

  const BleCharacteristic({
    required this.uuid,
    required this.canRead,
    required this.canWrite,
    required this.canNotify,
    this.value,
  });

  @override
  List<Object?> get props => [uuid, canRead, canWrite, canNotify, value];
}