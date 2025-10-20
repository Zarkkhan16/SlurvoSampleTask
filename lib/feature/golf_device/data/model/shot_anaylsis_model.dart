
import '../../domain/entities/shot_anaylsis_entity.dart';

class ShotAnalysisModel extends ShotAnalysisEntity {
  ShotAnalysisModel({
    required String id,
    required String userUid,
    required int shotNumber,
    required int clubName,
    required double clubSpeed,
    required double ballSpeed,
    required double smashFactor,
    required double carryDistance,
    required double totalDistance,
    required String date,
    required String time,
    required String sessionTime,
    required int timestamp,
  }) : super(
    id: id,
    userUid: userUid,
    shotNumber: shotNumber,
    clubName: clubName,
    clubSpeed: clubSpeed,
    ballSpeed: ballSpeed,
    smashFactor: smashFactor,
    carryDistance: carryDistance,
    totalDistance: totalDistance,
    date: date,
    time: time,
    sessionTime: sessionTime,
    timestamp: timestamp,
  );

  factory ShotAnalysisModel.fromMap(Map<String, dynamic> map, String docId) {
    return ShotAnalysisModel(
      id: docId,
      userUid: map['userUid'] as String? ?? '',
      shotNumber: (map['shotNumber'] as num?)?.toInt() ?? 0,
      clubName: (map['clubName'] as num?)?.toInt() ?? 0,
      clubSpeed: (map['clubSpeed'] as num?)?.toDouble() ?? 0.0,
      ballSpeed: (map['ballSpeed'] as num?)?.toDouble() ?? 0.0,
      smashFactor: (map['smashFactor'] as num?)?.toDouble() ?? 0.0,
      carryDistance: (map['carryDistance'] as num?)?.toDouble() ?? 0.0,
      totalDistance: (map['totalDistance'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      sessionTime: map['sessionTime'] as String? ?? '',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'shotNumber': shotNumber,
      'clubName': clubName,
      'clubSpeed': clubSpeed,
      'ballSpeed': ballSpeed,
      'smashFactor': smashFactor,
      'carryDistance': carryDistance,
      'totalDistance': totalDistance,
      'date': date,
      'time': time,
      'sessionTime': sessionTime,
      'timestamp': timestamp,
    };
  }
}
