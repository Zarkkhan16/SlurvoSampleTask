class ShotAnalysisEntity {
  final String id; // optional doc id
  final String userUid;
  final int shotNumber;
  final int clubName;
  final double clubSpeed;
  final double ballSpeed;
  final double smashFactor;
  final double carryDistance;
  final double totalDistance;
  final String date; // yyyy-mm-dd
  final String time; // HH:mm:ss
  final String sessionTime; // formatted elapsed
  final int timestamp; // epoch millis for sorting
  final bool isMeter;
  final int sessionNumber;
  final bool? isFavorite;

  ShotAnalysisEntity({
    required this.id,
    required this.userUid,
    required this.shotNumber,
    required this.clubName,
    required this.clubSpeed,
    required this.ballSpeed,
    required this.smashFactor,
    required this.carryDistance,
    required this.totalDistance,
    required this.date,
    required this.time,
    required this.sessionTime,
    required this.timestamp,
    required this.isMeter,
    required this.sessionNumber,
    this.isFavorite,
  });
}
