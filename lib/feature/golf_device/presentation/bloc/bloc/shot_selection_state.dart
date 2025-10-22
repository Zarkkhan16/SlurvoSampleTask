import '../../../data/model/shot_anaylsis_model.dart';

class ShotSelectionState {
  final int selectedIndex;
  final ShotAnalysisModel? selectedShot;

  ShotSelectionState({
    required this.selectedIndex,
    this.selectedShot,
  });

  ShotSelectionState copyWith({
    int? selectedIndex,
    ShotAnalysisModel? selectedShot,
  }) {
    return ShotSelectionState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedShot: selectedShot ?? this.selectedShot,
    );
  }
}