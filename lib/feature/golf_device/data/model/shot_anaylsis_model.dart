
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
    required bool isMeter,
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
    isMeter: isMeter,
  );

  ShotAnalysisModel copyWith({
    String? id,
    String? userUid,
    int? shotNumber,
    int? clubName,
    double? clubSpeed,
    double? ballSpeed,
    double? smashFactor,
    double? carryDistance,
    double? totalDistance,
    String? date,
    String? time,
    String? sessionTime,
    int? timestamp,
    bool? isMeter,
  }) {
    return ShotAnalysisModel(
      id: id ?? this.id,
      userUid: userUid ?? this.userUid,
      shotNumber: shotNumber ?? this.shotNumber,
      clubName: clubName ?? this.clubName,
      clubSpeed: clubSpeed ?? this.clubSpeed,
      ballSpeed: ballSpeed ?? this.ballSpeed,
      smashFactor: smashFactor ?? this.smashFactor,
      carryDistance: carryDistance ?? this.carryDistance,
      totalDistance: totalDistance ?? this.totalDistance,
      date: date ?? this.date,
      time: time ?? this.time,
      sessionTime: sessionTime ?? this.sessionTime,
      timestamp: timestamp ?? this.timestamp,
      isMeter: isMeter ?? this.isMeter,
    );
  }

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
      isMeter: map['isMeter'] as bool? ?? false,
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
      'isMeter': isMeter,
    };
  }
}
