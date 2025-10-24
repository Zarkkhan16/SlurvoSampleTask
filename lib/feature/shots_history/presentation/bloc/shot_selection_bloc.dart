import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/shots_history/presentation/bloc/shot_selection_event.dart';
import 'package:onegolf/feature/shots_history/presentation/bloc/shot_selection_state.dart';
import '../../../choose_club_screen/model/club_model.dart';
import '../../../golf_device/data/model/shot_anaylsis_model.dart';
import '../../../golf_device/domain/repositories/ble_repository.dart';
import '../../../golf_device/domain/usecases/send_command_usecase.dart';
import '../../../golf_device/presentation/bloc/golf_device_bloc.dart';

class ShotHistoryBloc extends Bloc<ShotHistoryEvent, ShotHistoryState> {
  final BleRepository bleRepository;
  final User? user;
  final SendCommandUseCase sendCommandUseCase;
  final GolfDeviceBloc golfDeviceBloc;

  ShotHistoryBloc({
    required this.bleRepository,
    required this.user,
    required this.sendCommandUseCase,
    required this.golfDeviceBloc,
  }) : super(ShotHistoryInitialState()) {

    golfDeviceBloc.bleResponseStream.listen((data) {
      print("📩 BLE response received: $data");

      if (data.length >= 6) {
        print("🔍 Checking bytes: ${data[2]}, ${data[3]}, ${data[4]}");
      }
      if (data.length >= 6 && data[2] == 0x05 && data[3] == 0x4F && data[4] == 0x4B) {
        add(ClearRecordResponseReceivedEvent());
      }
    });

    on<LoadShotHistoryEvent>(_onLoadShotHistory);
    on<SelectShotEvent>(_onSelectShot);
    on<LoadInitialShotEvent>(_onLoadInitialShot);
    on<ClearRecordEvent>(_onClearRecord);
    on<ClearRecordResponseReceivedEvent>(_onClearRecordResponse);
    on<UpdateFilterEvent>(_onUpdateFilter);
  }

  Future<void> _onLoadShotHistory(
      LoadShotHistoryEvent event,
      Emitter<ShotHistoryState> emit,
      ) async {
    emit(ShotHistoryLoadingState());
    try {
      final userId = user?.uid ?? '';
      if (userId.isEmpty) {
        emit(ShotHistoryErrorState('User not authenticated'));
        return;
      }

      final shots = await bleRepository.fetchShotsForUser(userId);

      if (shots.isEmpty) {
        emit(ShotHistoryLoadedState(
          shots: [],
          selectedIndex: -1,
          selectedShot: null,
        ));
      } else {
        emit(ShotHistoryLoadedState(
          shots: shots,
          selectedIndex: 0,
          selectedShot: shots[0],
        ));
      }
    } catch (e) {
      emit(ShotHistoryErrorState(e.toString()));
    }
  }

  void _onSelectShot(SelectShotEvent event, Emitter<ShotHistoryState> emit) {
    final currentState = state;
    if (currentState is ShotHistoryLoadedState) {
      if (event.index >= 0 && event.index < currentState.shots.length) {
        emit(currentState.copyWith(
          selectedIndex: event.index,
          selectedShot: currentState.shots[event.index],
        ));
      }
    }
  }

  void _onLoadInitialShot(
      LoadInitialShotEvent event,
      Emitter<ShotHistoryState> emit,
      ) {
    final currentState = state;
    if (currentState is ShotHistoryLoadedState && currentState.shots.isNotEmpty) {
      emit(currentState.copyWith(
        selectedIndex: 0,
        selectedShot: currentState.shots[0],
      ));
    }
  }

  Future<void> _onClearRecord(
      ClearRecordEvent event,
      Emitter<ShotHistoryState> emit,
      ) async {
    try {
      emit(ClearingRecordState());
      await sendCommandUseCase.call(0x05, 0x00, 0x00);
      print("📤 Sent Clear All Records command to device, waiting for response...");
      add(ClearRecordResponseReceivedEvent());
    } catch (e) {
      emit(ShotHistoryErrorState("Failed to send command: $e"));
    }
  }

  Future<void> _onClearRecordResponse(
      ClearRecordResponseReceivedEvent event,
      Emitter<ShotHistoryState> emit,
      ) async {
    try {
      final userId = user?.uid ?? '';
      if (userId.isEmpty) {
        emit(ShotHistoryErrorState('User not authenticated'));
        return;
      }

      await bleRepository.deleteAllShotsForUser(userId);
      print("🗑️ All shots deleted from Firebase for $userId");

      // emit(ShotHistoryLoadedState(
      //   shots: [],
      //   selectedIndex: -1,
      //   selectedShot: null,
      // ));
      emit(const ShotHistoryClearedState());
    } catch (e) {
      emit(ShotHistoryErrorState("Failed to clear records: $e"));
    }
  }

  void _onUpdateFilter(
      UpdateFilterEvent event,
      Emitter<ShotHistoryState> emit,
      ) {
    final currentState = state;
    if (currentState is ShotHistoryLoadedState) {
      print('📊 Updating filter with ${event.selectedClubs.length} clubs');
      event.selectedClubs.forEach((club) {
        print('   - ${club.name} (${club.code})');
      });

      final filteredShots = _getFilteredShots(currentState.shots, event.selectedClubs);
      print('🎯 Filtered shots count: ${filteredShots.length} out of ${currentState.shots.length}');

      emit(currentState.copyWith(
        selectedClubs: event.selectedClubs,
        selectedIndex: filteredShots.isNotEmpty ? 0 : -1,
        selectedShot: filteredShots.isNotEmpty ? filteredShots[0] : null,
        clearSelectedShot: filteredShots.isEmpty,
      ));
    }
  }

  List<ShotAnalysisModel> _getFilteredShots(
      List<ShotAnalysisModel> allShots,
      List<Club> selectedClubs,
      ) {
    if (selectedClubs.isEmpty) {
      return allShots;
    }

    // Convert club codes to integers for comparison
    final selectedClubCodes = selectedClubs
        .map((c) => int.tryParse(c.code) ?? -1)
        .where((code) => code != -1)
        .toSet();

    return allShots.where((shot) => selectedClubCodes.contains(shot.clubName)).toList();
  }
}
