import 'package:equatable/equatable.dart';
class ShotResult extends Equatable {
  final int actualCarry;
  final DateTime timestamp;
  final bool isWithinTarget;

  const ShotResult({
    required this.actualCarry,
    required this.timestamp,
    required this.isWithinTarget,
  });

  @override
  List<Object?> get props => [actualCarry, timestamp, isWithinTarget];
}
