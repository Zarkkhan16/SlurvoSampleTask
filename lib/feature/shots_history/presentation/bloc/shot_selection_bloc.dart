import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/shots_history/presentation/bloc/shot_selection_event.dart';
import 'package:onegolf/feature/shots_history/presentation/bloc/shot_selection_state.dart';
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
}
