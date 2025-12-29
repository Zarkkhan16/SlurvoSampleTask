import 'dart:math' as math;

class GolfDataEntity {
  final int battery;
  final int recordNumber;
  final int clubName;
  final double clubSpeed;
  final double ballSpeed;
  final double carryDistance;
  final double totalDistance;

  const GolfDataEntity({
    required this.battery,
    required this.recordNumber,
    required this.clubName,
    required this.clubSpeed,
    required this.ballSpeed,
    required this.carryDistance,
    required this.totalDistance,
  });

  double get smashFactor {
    if (clubSpeed <= 0) return 0.0;

    final raw = ballSpeed / clubSpeed;
    final factor = math.pow(10, 2);
    return (raw * factor).truncate() / factor;
  }

  GolfDataEntity copyWith({
    int? battery,
    int? recordNumber,
    int? clubName,
    double? clubSpeed,
    double? ballSpeed,
    double? carryDistance,
    double? totalDistance,
  }) {
    return GolfDataEntity(
      battery: battery ?? this.battery,
      recordNumber: recordNumber ?? this.recordNumber,
      clubName: clubName ?? this.clubName,
      clubSpeed: clubSpeed ?? this.clubSpeed,
      ballSpeed: ballSpeed ?? this.ballSpeed,
      carryDistance: carryDistance ?? this.carryDistance,
      totalDistance: totalDistance ?? this.totalDistance,
    );
  }
}
