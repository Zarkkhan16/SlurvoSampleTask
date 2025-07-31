import 'package:equatable/equatable.dart';
import 'package:sample_task/feature/ble/domain/entities/ble_characteristic.dart';

class BleService extends Equatable {
  final String uuid;
  final List<BleCharacteristic> characteristics;

  const BleService({
    required this.uuid,
    required this.characteristics,
  });

  @override
  List<Object?> get props => [uuid, characteristics];
}