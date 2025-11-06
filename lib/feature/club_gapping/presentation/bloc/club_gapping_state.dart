// ============================================================
// CLUB GAPPING - BLOC STATES
// ============================================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/club_entity.dart';
import '../../domain/entities/club_gapping_session_entity.dart';
import '../../domain/entities/club_summary_entity.dart';
import '../../domain/entities/shot_entity.dart';

abstract class ClubGappingState extends Equatable {
  @override
  List<Object?> get props => [];
}

// ============================================================
// INITIAL & LOADING STATES
// ============================================================

/// Initial state
class ClubGappingInitial extends ClubGappingState {}

/// Loading clubs
class ClubGappingLoading extends ClubGappingState {}

// ============================================================
// CLUB SELECTION STATE
// ============================================================

/// Club selection screen
class ClubSelectionState extends ClubGappingState {
  final List<ClubEntity> availableClubs;
  final List<ClubEntity> selectedClubs;
  final int shotsPerClub;
  final bool canStartSession;
  final bool isCustomSelected;

  ClubSelectionState({
    required this.availableClubs,
    required this.selectedClubs,
    this.shotsPerClub = 3,
    this.canStartSession = false,
    this.isCustomSelected = false,
  });

  ClubSelectionState copyWith({
    List<ClubEntity>? availableClubs,
    List<ClubEntity>? selectedClubs,
    int? shotsPerClub,
    bool? canStartSession,
    bool? isCustomSelected,
  }) {
    return ClubSelectionState(
      availableClubs: availableClubs ?? this.availableClubs,
      selectedClubs: selectedClubs ?? this.selectedClubs,
      shotsPerClub: shotsPerClub ?? this.shotsPerClub,
      canStartSession: canStartSession ?? this.canStartSession,
      isCustomSelected: isCustomSelected ?? this.isCustomSelected,
    );
  }

  @override
  List<Object?> get props => [
        availableClubs,
        selectedClubs,
        shotsPerClub,
        canStartSession,
        isCustomSelected,
      ];
}

// ============================================================
// SHOT RECORDING STATE
// ============================================================

/// Recording shots for a club
class RecordingShotsState extends ClubGappingState {
  final ClubGappingSessionEntity session;
  final ClubEntity currentClub;
  final List<ShotEntity> currentClubShots;
  final int currentShotNumber;
  final int totalShots;
  final ShotEntity? latestShot;
  final bool isWaitingForShot;

  RecordingShotsState({
    required this.session,
    required this.currentClub,
    required this.currentClubShots,
    required this.currentShotNumber,
    required this.totalShots,
    this.latestShot,
    this.isWaitingForShot = true,
  });

  RecordingShotsState copyWith({
    ClubGappingSessionEntity? session,
    ClubEntity? currentClub,
    List<ShotEntity>? currentClubShots,
    int? currentShotNumber,
    int? totalShots,
    ShotEntity? latestShot,
    bool? isWaitingForShot,
  }) {
    return RecordingShotsState(
      session: session ?? this.session,
      currentClub: currentClub ?? this.currentClub,
      currentClubShots: currentClubShots ?? this.currentClubShots,
      currentShotNumber: currentShotNumber ?? this.currentShotNumber,
      totalShots: totalShots ?? this.totalShots,
      latestShot: latestShot ?? this.latestShot,
      isWaitingForShot: isWaitingForShot ?? this.isWaitingForShot,
    );
  }

  @override
  List<Object?> get props => [
        session,
        currentClub,
        currentClubShots,
        currentShotNumber,
        totalShots,
        latestShot,
        isWaitingForShot,
      ];
}

// ============================================================
// CLUB SUMMARY STATE
// ============================================================

/// Show summary for completed club
class ClubSummaryState extends ClubGappingState {
  final ClubGappingSessionEntity session;
  final ClubSummaryEntity clubSummary;
  final bool hasNextClub;
  final ClubEntity? nextClub;

  ClubSummaryState({
    required this.session,
    required this.clubSummary,
    required this.hasNextClub,
    this.nextClub,
  });

  @override
  List<Object?> get props => [
        session,
        clubSummary,
        hasNextClub,
        nextClub,
      ];
}

// ============================================================
// FINAL SESSION SUMMARY STATE
// ============================================================

/// Show final summary for all clubs
class SessionSummaryState extends ClubGappingState {
  final ClubGappingSessionEntity session;
  final List<ClubSummaryEntity> clubSummaries;
  final Map<String, double> clubAverages; // clubId -> average carry distance

  SessionSummaryState({
    required this.session,
    required this.clubSummaries,
    required this.clubAverages,
  });

  @override
  List<Object?> get props => [
        session,
        clubSummaries,
        clubAverages,
      ];
}

// ============================================================
// ERROR & SAVING STATES
// ============================================================

/// Error state
class ClubGappingError extends ClubGappingState {
  final String message;
  final ClubGappingState? previousState;

  ClubGappingError({
    required this.message,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

/// Saving session
class SavingSessionState extends ClubGappingState {
  final ClubGappingSessionEntity session;

  SavingSessionState(this.session);

  @override
  List<Object?> get props => [session];
}

/// Session saved successfully
class SessionSavedState extends ClubGappingState {
  final String sessionId;

  SessionSavedState(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}