import '../../../golf_device/data/model/shot_anaylsis_model.dart';

class ShotLibraryState {
  final List<ShotAnalysisModel> allShots;
  final Map<String, List<ShotAnalysisModel>> shotsByDate;
  final int totalShots;
  final int? mostUsedClub;
  final bool showFavorites;
  final DateTime filterStartDate;
  final DateTime filterEndDate;
  final bool isLoading;

  ShotLibraryState({
    this.allShots = const [],
    this.shotsByDate = const {},
    this.totalShots = 0,
    this.mostUsedClub,
    this.showFavorites = false,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    this.isLoading = true,
  }) : filterStartDate = filterStartDate ?? DateTime.now(),
        filterEndDate = filterEndDate ?? DateTime.now();

  ShotLibraryState copyWith({
    List<ShotAnalysisModel>? allShots,
    Map<String, List<ShotAnalysisModel>>? shotsByDate,
    int? totalShots,
    int? mostUsedClub,
    bool? showFavorites,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool? isLoading,
  }) {
    return ShotLibraryState(
      allShots: allShots ?? this.allShots,
      shotsByDate: shotsByDate ?? this.shotsByDate,
      totalShots: totalShots ?? this.totalShots,
      mostUsedClub: mostUsedClub ?? this.mostUsedClub,
      showFavorites: showFavorites ?? this.showFavorites,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}