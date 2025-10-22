import 'package:equatable/equatable.dart';
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

  const ShotHistoryLoadedState({
    required this.shots,
    required this.selectedIndex,
    this.selectedShot,
  });

  ShotHistoryLoadedState copyWith({
    List<ShotAnalysisModel>? shots,
    int? selectedIndex,
    ShotAnalysisModel? selectedShot,
  }) {
    return ShotHistoryLoadedState(
      shots: shots ?? this.shots,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedShot: selectedShot ?? this.selectedShot,
    );
  }

  @override
  List<Object?> get props => [shots, selectedIndex, selectedShot];
}

/// 🔹 State when clear command is being processed
class ClearingRecordState extends ShotHistoryState {
  const ClearingRecordState();
}

/// 🔹 State after clear command success
class ShotHistoryClearedState extends ShotHistoryState {
  const ShotHistoryClearedState();
}
