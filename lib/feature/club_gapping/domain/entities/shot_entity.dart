import 'package:equatable/equatable.dart';

class ShotEntity extends Equatable {
  final String id;
  final String clubId;
  final int shotNumber;
  final double carryDistance;
  final double totalDistance;
  final double clubSpeed;
  final double ballSpeed;
  final double smashFactor;
  final DateTime timestamp;
  final int starRating; // 1-5

  const ShotEntity({
    required this.id,
    required this.clubId,
    required this.shotNumber,
    required this.carryDistance,
    required this.totalDistance,
    required this.clubSpeed,
    required this.ballSpeed,
    required this.smashFactor,
    required this.timestamp,
    this.starRating = 3,
  });

  @override
  List<Object?> get props => [
    id,
    clubId,
    shotNumber,
    carryDistance,
    totalDistance,
    clubSpeed,
    ballSpeed,
    smashFactor,
    timestamp,
    starRating,
  ];
}