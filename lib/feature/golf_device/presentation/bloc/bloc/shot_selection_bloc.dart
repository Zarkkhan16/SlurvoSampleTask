import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/bloc/shot_selection_event.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/bloc/shot_selection_state.dart';

import '../../../data/model/shot_anaylsis_model.dart';

class ShotSelectionBloc extends Bloc<ShotSelectionEvent, ShotSelectionState> {
  final List<ShotAnalysisModel> shots;

  ShotSelectionBloc(this.shots)
      : super(ShotSelectionState(
    selectedIndex: 0,
    selectedShot: shots.isNotEmpty ? shots[0] : null,
  )) {
    on<SelectShotEvent>(_onSelectShot);
    on<LoadInitialShotEvent>(_onLoadInitialShot);
  }

  void _onSelectShot(SelectShotEvent event, Emitter<ShotSelectionState> emit) {
    if (event.index >= 0 && event.index < shots.length) {
      emit(state.copyWith(
        selectedIndex: event.index,
        selectedShot: shots[event.index],
      ));
    }
  }

  void _onLoadInitialShot(
      LoadInitialShotEvent event, Emitter<ShotSelectionState> emit) {
    if (shots.isNotEmpty) {
      emit(state.copyWith(
        selectedIndex: 0,
        selectedShot: shots[0],
      ));
    }
  }
}