import 'package:equatable/equatable.dart';
import '../../domain/entities/club_entity.dart';
import '../../domain/entities/shot_entity.dart';

abstract class ClubGappingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load available clubs for selection
class LoadAvailableClubsEvent extends ClubGappingEvent {}

/// Toggle club selection
class ToggleClubSelectionEvent extends ClubGappingEvent {
  final String clubId;

  ToggleClubSelectionEvent(this.clubId);

  @override
  List<Object?> get props => [clubId];
}

/// Update shots per club
class UpdateShotsPerClubEvent extends ClubGappingEvent {
  final int shotsPerClub;

  UpdateShotsPerClubEvent(this.shotsPerClub);

  @override
  List<Object?> get props => [shotsPerClub];
}

/// Start gapping session with selected clubs
class StartGappingSessionEvent extends ClubGappingEvent {
  final List<ClubEntity> selectedClubs;
  final int shotsPerClub;

  StartGappingSessionEvent({
    required this.selectedClubs,
    required this.shotsPerClub,
  });

  @override
  List<Object?> get props => [selectedClubs, shotsPerClub];
}

// ============================================================
// SHOT RECORDING EVENTS
// ============================================================

/// Receive shot data from BLE device
class ShotDataReceivedEvent extends ClubGappingEvent {
  final double carryDistance;
  final double totalDistance;
  final double clubSpeed;
  final double ballSpeed;
  final double smashFactor;

  ShotDataReceivedEvent({
    required this.carryDistance,
    required this.totalDistance,
    required this.clubSpeed,
    required this.ballSpeed,
    required this.smashFactor,
  });

  @override
  List<Object?> get props => [
    carryDistance,
    totalDistance,
    clubSpeed,
    ballSpeed,
    smashFactor,
  ];
}

/// Record a shot for current club
class RecordShotEvent extends ClubGappingEvent {
  final ShotEntity shot;

  RecordShotEvent(this.shot);

  @override
  List<Object?> get props => [shot];
}

/// Re-hit current shot
class ReHitShotEvent extends ClubGappingEvent {}

/// Delete last shot (if re-hitting)
class DeleteLastShotEvent extends ClubGappingEvent {}

// ============================================================
// NAVIGATION EVENTS
// ============================================================

/// Complete current club and show summary
class CompleteCurrentClubEvent extends ClubGappingEvent {}

/// Re-take gapping for current club
class RetakeCurrentClubEvent extends ClubGappingEvent {}

/// Move to next club
class MoveToNextClubEvent extends ClubGappingEvent {}

/// Go to specific club
class GoToClubEvent extends ClubGappingEvent {
  final int clubIndex;

  GoToClubEvent(this.clubIndex);

  @override
  List<Object?> get props => [clubIndex];
}

// ============================================================
// SESSION MANAGEMENT EVENTS
// ============================================================

/// Complete entire gapping session
class CompleteSessionEvent extends ClubGappingEvent {}

/// Re-take entire gapping session
class RetakeSessionEvent extends ClubGappingEvent {}

/// Save session to Firestore
class SaveSessionEvent extends ClubGappingEvent {}

/// Load saved session
class LoadSessionEvent extends ClubGappingEvent {
  final String sessionId;

  LoadSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Exit session
class ExitSessionEvent extends ClubGappingEvent {}
class SubcribeToBleShotData extends ClubGappingEvent {}

/// Reset to club selection
class ResetToSelectionEvent extends ClubGappingEvent {}
class SelectCustomShotsEvent extends ClubGappingEvent {}
class StopListeningToBleDataClubEvent extends ClubGappingEvent {}