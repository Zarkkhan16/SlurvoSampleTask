import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_event.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_state.dart';

class PracticeGamesBloc extends Bloc<PracticeGamesEvent, PracticeGamesState> {
  PracticeGamesBloc() : super(PracticeGamesState()) {
    on<SelectShotsEvent>(_onSelectShots);
    on<SelectCustomEvent>(_onSelectCustom);
    on<UpdateCustomShotsEvent>(_onUpdateCustomShots);
    on<AddPlayerEvent>(_onAddPlayer);
    on<NextAttemptEvent>(_onNextAttempt);
    on<ResetSessionEvent>(_onResetSession);
  }

  void _onSelectShots(SelectShotsEvent event, Emitter<PracticeGamesState> emit) {
    emit(state.copyWith(
      selectedShots: event.shots,
      isCustomSelected: false,
    ));
  }

  void _onSelectCustom(SelectCustomEvent event, Emitter<PracticeGamesState> emit) {
    emit(state.copyWith(
      isCustomSelected: true,
      selectedShots: 0,
    ));
  }

  void _onUpdateCustomShots(UpdateCustomShotsEvent event, Emitter<PracticeGamesState> emit) {
    final num? entered = int.tryParse(event.value);
    if (entered != null && entered <= 10) {
      emit(state.copyWith(selectedShots: entered.toInt()));
    }
  }

  void _onAddPlayer(AddPlayerEvent event, Emitter<PracticeGamesState> emit) {
    if (state.canAddPlayer) {
      final updatedPlayers = List<String>.from(state.players)
        ..add("Player ${state.players.length}");
      emit(state.copyWith(players: updatedPlayers));
    }
  }

  void _onNextAttempt(NextAttemptEvent event, Emitter<PracticeGamesState> emit) {
    emit(state.copyWith(currentAttempt: state.currentAttempt + 1));
  }

  void _onResetSession(ResetSessionEvent event, Emitter<PracticeGamesState> emit) {
    emit(state.copyWith(currentAttempt: 1));
  }
}