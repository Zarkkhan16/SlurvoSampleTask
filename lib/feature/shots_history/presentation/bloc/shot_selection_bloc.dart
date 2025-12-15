import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/golf_device/data/datasources/shot_firestore_datasource.dart';
import 'package:onegolf/feature/shots_history/presentation/bloc/shot_selection_event.dart';
import 'package:onegolf/feature/shots_history/presentation/bloc/shot_selection_state.dart';
import '../../../choose_club_screen/model/club_model.dart';
import '../../../golf_device/data/model/shot_anaylsis_model.dart';
import '../../../golf_device/domain/repositories/ble_repository.dart';
import '../../../golf_device/domain/usecases/send_command_usecase.dart';
import '../../../golf_device/presentation/bloc/golf_device_bloc.dart';

class ShotHistoryBloc extends Bloc<ShotHistoryEvent, ShotHistoryState> {
  final BleManagementRepository bleRepository;
  final ShotFirestoreDatasource datasource;
  final User? user;
  final GolfDeviceBloc golfDeviceBloc;
  List<ShotAnalysisModel> shots = [];
  ShotHistoryBloc({
    required this.bleRepository,
    required this.datasource,
    required this.user,
    required this.golfDeviceBloc,
  }) : super(ShotHistoryInitialState()) {
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

      final now = DateTime.now();
      final date =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      // final sessionNumber = await datasource.getTodayNextSessionNumber(userId, date);
      // print(sessionNumber-1);
      // shots = await datasource.fetchShotsForUser(userId, date, sessionNumber-1);
      final allShots = await datasource.fetchShotsForUser(userId, date);
      shots = allShots.where((s) => s.sessionNumber == event.sessionNumber).toList();

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
      List<int> packet = [0x47, 0x46, 0x05, 0x00, 0x00];
      await bleRepository.writeData(packet);
      print("📤 Sent Clear All Records command to device, waiting for response...");
      add(ClearRecordResponseReceivedEvent(sessionNumber: event.sessionNumber));
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

      final now = DateTime.now();
      final date =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      // final sessionNumber = await datasource.getTodayNextSessionNumber(userId, date);
      // await datasource.deleteAllSessionsForDate(userId, date);
      await datasource.deleteSession(userId, date, event.sessionNumber);
      print("🗑️ All shots deleted from Firebase for $userId");
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
    final selectedClubCodes = selectedClubs
        .map((c) => int.tryParse(c.code) ?? -1)
        .where((code) => code != -1)
        .toSet();

    return allShots.where((shot) => selectedClubCodes.contains(shot.clubName)).toList();
  }
}
