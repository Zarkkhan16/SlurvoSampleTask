import 'package:equatable/equatable.dart';
import '../../../choose_club_screen/model/club_model.dart';
import '../../../golf_device/data/model/shot_anaylsis_model.dart';

/// 🔹 Base abstract state class
abstract class ShotHistoryState extends Equatable {
  const ShotHistoryState();

  @override
  List<Object?> get props => [];
}

/// 🔹 Initial state when nothing is loaded yet
class ShotHistoryInitialState extends ShotHistoryState {
  const ShotHistoryInitialState();
}

/// 🔹 Loading while fetching data
class ShotHistoryLoadingState extends ShotHistoryState {
  const ShotHistoryLoadingState();
}

/// 🔹 Error state with a message
class ShotHistoryErrorState extends ShotHistoryState {
  final String message;

  const ShotHistoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// 🔹 Loaded state containing all shots
class ShotHistoryLoadedState extends ShotHistoryState {
  final List<ShotAnalysisModel> shots;
  final int selectedIndex;
  final ShotAnalysisModel? selectedShot;
  final List<Club> selectedClubs;

  const ShotHistoryLoadedState({
    required this.shots,
    required this.selectedIndex,
    this.selectedShot,
    this.selectedClubs = const [],
  });

  List<ShotAnalysisModel> get filteredShots {
    if (selectedClubs.isEmpty) {
      return shots;
    }
    // Convert club codes to integers for comparison
    final selectedClubCodes = selectedClubs
        .map((c) => int.tryParse(c.code) ?? -1)
        .where((code) => code != -1)
        .toSet();

    return shots.where((shot) => selectedClubCodes.contains(shot.clubName)).toList();
  }

  ShotHistoryLoadedState copyWith({
    List<ShotAnalysisModel>? shots,
    int? selectedIndex,
    ShotAnalysisModel? selectedShot,
    List<Club>? selectedClubs,
    bool clearSelectedShot = false,
  }) {
    return ShotHistoryLoadedState(
      shots: shots ?? this.shots,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedShot: selectedShot ?? this.selectedShot,
      selectedClubs: selectedClubs ?? this.selectedClubs,
    );
  }

  @override
  List<Object?> get props => [shots, selectedIndex, selectedShot, selectedClubs];
}

/// 🔹 State when clear command is being processed
class ClearingRecordState extends ShotHistoryState {
  const ClearingRecordState();
}

/// 🔹 State after clear command success
class ShotHistoryClearedState extends ShotHistoryState {
  const ShotHistoryClearedState();
}
