import 'package:equatable/equatable.dart';
import 'package:onegolf/feature/club_gapping/domain/entities/shot_entity.dart';

import 'club_entity.dart';

class ClubGappingSessionEntity extends Equatable {
  final String id;
  final List<ClubEntity> selectedClubs;
  final int shotsPerClub;
  final int currentClubIndex;
  final Map<String, List<ShotEntity>> clubShots;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;

  const ClubGappingSessionEntity({
    required this.id,
    required this.selectedClubs,
    required this.shotsPerClub,
    this.currentClubIndex = 0,
    this.clubShots = const {},
    required this.startTime,
    this.endTime,
    this.status = SessionStatus.active,
  });

  // Get current club
  ClubEntity? get currentClub {
    if (currentClubIndex < selectedClubs.length) {
      return selectedClubs[currentClubIndex];
    }
    return null;
  }

  // Get shots for current club
  List<ShotEntity> get currentClubShots {
    if (currentClub != null) {
      return clubShots[currentClub!.id] ?? [];
    }
    return [];
  }

  // Check if current club is complete
  bool get isCurrentClubComplete {
    return currentClubShots.length >= shotsPerClub;
  }

  // Check if session is complete
  bool get isSessionComplete {
    return currentClubIndex >= selectedClubs.length;
  }

  // Get average carry distance for a club
  double getAverageCarryDistance(String clubId) {
    final shots = clubShots[clubId] ?? [];
    if (shots.isEmpty) return 0.0;
    final total = shots.fold<double>(
      0.0,
          (sum, shot) => sum + shot.carryDistance,
    );
    return total / shots.length;
  }

  ClubGappingSessionEntity copyWith({
    String? id,
    List<ClubEntity>? selectedClubs,
    int? shotsPerClub,
    int? currentClubIndex,
    Map<String, List<ShotEntity>>? clubShots,
    DateTime? startTime,
    DateTime? endTime,
    SessionStatus? status,
  }) {
    return ClubGappingSessionEntity(
      id: id ?? this.id,
      selectedClubs: selectedClubs ?? this.selectedClubs,
      shotsPerClub: shotsPerClub ?? this.shotsPerClub,
      currentClubIndex: currentClubIndex ?? this.currentClubIndex,
      clubShots: clubShots ?? this.clubShots,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    selectedClubs,
    shotsPerClub,
    currentClubIndex,
    clubShots,
    startTime,
    endTime,
    status,
  ];
}

enum SessionStatus {
  active,
  paused,
  completed,
}