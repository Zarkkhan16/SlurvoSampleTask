import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../golf_device/data/datasources/shot_firestore_datasource.dart';
import '../../../golf_device/data/model/shot_anaylsis_model.dart';
import 'shot_library_event.dart';
import 'shot_library_state.dart';
import 'package:collection/collection.dart';

class ShotLibraryBloc extends Bloc<ShotLibraryEvent, ShotLibraryState> {
  final ShotFirestoreDatasource datasource;

  ShotLibraryBloc({required this.datasource}) : super(ShotLibraryState()) {
    on<LoadAllShots>(_onLoadAllShots);
    on<UpdateStartDate>(_onUpdateStartDate);
    on<UpdateEndDate>(_onUpdateEndDate);
    on<FilterShotsByDate>(_onFilterShotsByDate);
    on<ApplyFilters>(_onApplyFilters);
    on<ToggleShowFavorites>(_onToggleShowFavorites);
    on<ClearFilters>(_onClearFilters);
    on<ToggleSessionFavorite>(_onToggleSessionFavorite);
  }

  Future<void> _onLoadAllShots(
    LoadAllShots event,
    Emitter<ShotLibraryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final shots = await datasource.fetchAllShotsForUser(event.userUid);

    final Map<String, List<ShotAnalysisModel>> byDate =
    groupBy(shots, (ShotAnalysisModel shot) => shot.date);

    final total = shots.length;

    int? mostUsedClub;
    int maxCount = 0;

    final Map<dynamic, List<ShotAnalysisModel>> clubGroups =
    groupBy(shots, (ShotAnalysisModel e) => e.clubName);

    clubGroups.forEach((club, clubShots) {
      if (clubShots.length > maxCount) {
        maxCount = clubShots.length;
        mostUsedClub = club;
      }
    });

    emit(state.copyWith(
      allShots: shots,
      shotsByDate: byDate,
      totalShots: total,
      mostUsedClub: mostUsedClub,
      isLoading: false,
    ));
  }

  void _onUpdateStartDate(UpdateStartDate e, Emitter emit) {
    emit(state.copyWith(filterStartDate: e.startDate));
  }

  void _onUpdateEndDate(UpdateEndDate e, Emitter emit) {
    emit(state.copyWith(filterEndDate: e.endDate));
  }

  Future<void> _onToggleSessionFavorite(
      ToggleSessionFavorite event,
      Emitter<ShotLibraryState> emit,
      ) async {

    emit(state.copyWith(
      isLoading: true,
    ));

    await datasource.updateSessionFavorite(
      userUid: event.userUid,
      date: event.date,
      sessionNumber: event.sessionNumber,
      isFavorite: event.isFavorite,
    );

    final updatedShots = state.allShots.map((shot) {
      if (shot.date == event.date &&
          shot.sessionNumber == event.sessionNumber) {
        return shot.copyWith(isFavorite: event.isFavorite);
      }
      return shot;
    }).toList();

    emit(state.copyWith(
      allShots: updatedShots,
      shotsByDate: groupBy(updatedShots, (s) => s.date),
      isLoading: false,
    ));
  }

  void _onFilterShotsByDate(
    FilterShotsByDate event,
    Emitter<ShotLibraryState> emit,
  ) {
    final filtered = state.allShots.where((shot) {
      final d = DateTime.parse(shot.date);
      return !d.isBefore(event.startDate) && !d.isAfter(event.endDate);
    }).toList();

    final byDate = groupBy(filtered, (s) => s.date);

    emit(state.copyWith(
      shotsByDate: byDate,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
    ));
  }

  void _onApplyFilters(ApplyFilters e, Emitter emit) {
    var shots = state.allShots.where((s) {
      final d = DateTime.parse(s.date);
      return !d.isBefore(state.filterStartDate) &&
          !d.isAfter(state.filterEndDate);
    }).toList();

    if (state.showFavorites) {
      shots = shots.where((s) => s.isFavorite == true).toList();
    }

    emit(state.copyWith(
      shotsByDate: groupBy(shots, (s) => s.date),
    ));
  }

  void _onToggleShowFavorites(
    ToggleShowFavorites event,
    Emitter<ShotLibraryState> emit,
  ) {
    final showFav = !state.showFavorites;

    final shots = showFav
        ? state.allShots.where((s) => s.isFavorite == true).toList()
        : state.allShots;

    final byDate = groupBy(shots, (s) => s.date);

    emit(state.copyWith(
      showFavorites: showFav,
      shotsByDate: byDate,
    ));
  }

  void _onClearFilters(
      ClearFilters event,
      Emitter<ShotLibraryState> emit,
      ) {
    final now = DateTime.now();
    final byDate = groupBy(state.allShots, (s) => s.date);

    emit(state.copyWith(
      shotsByDate: byDate,
      filterStartDate: now,
      filterEndDate: now,
      showFavorites: false,
    ));
  }

}
