import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../golf_device/data/services/ble_service.dart';
import '../../../golf_device/domain/entities/device_entity.dart';
import '../../../golf_device/domain/usecases/send_command_usecase.dart';
import 'setting_event.dart';
import 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SendCommandUseCase sendCommandUseCase;
  final SharedPreferences sharedPreferences;
  final BleService bleService;
  DeviceEntity? _device;

  SettingBloc({
    required this.sendCommandUseCase,
    required this.sharedPreferences,
    required this.bleService,
  }) : super(SettingInitial()) {
    on<LoadSettingsEvent>(_onLoad);
    on<ToggleBacklightEvent>(_onToggleBacklight);
    on<UpdateSleepTimeLocally>(_onUpdateSleepTimeLocally);
    on<SendSleepTimeCommandEvent>(_onSendSleepTime);
    on<ChangeUnitEvent>(_onChangeUnit);
  }

  Future<void> _onLoad(LoadSettingsEvent event, Emitter emit) async {
    emit(SettingLoading());
    _device = event.device;

    await Future.delayed(const Duration(milliseconds: 500));

    final backlight = sharedPreferences.getBool('backlight') ?? false;
    final sleepTime = sharedPreferences.getInt('sleepTime') ?? 5;
    final meters = sharedPreferences.getBool('unit') ?? event.initialUnit;

    emit(SettingLoaded(backlight: backlight, sleepTime: sleepTime, meters: meters));
  }

  Future<void> _onToggleBacklight(ToggleBacklightEvent event, Emitter emit) async {
    final cur = state;
    if (cur is! SettingLoaded || _device == null) return;

    emit(cur.copyWith(isSending: true));
    try {
      await sendCommandUseCase.call(0x06, event.enabled ? 1 : 0, 0x00);
      await sharedPreferences.setBool('backlight', event.enabled);
      emit(cur.copyWith(backlight: event.enabled, isSending: false));
    } catch (e) {
      emit(SettingError('Failed to set backlight: $e'));
      emit(cur.copyWith(isSending: false));
    }
  }

  void _onUpdateSleepTimeLocally(UpdateSleepTimeLocally event, Emitter<SettingState> emit) {
    final cur = state;
    if (cur is SettingLoaded) {
      emit(cur.copyWith(sleepTime: event.newValue));
    }
  }

  Future<void> _onSendSleepTime(SendSleepTimeCommandEvent event, Emitter emit) async {
    final cur = state;
    if (cur is! SettingLoaded || _device == null) return;

    emit(cur.copyWith(isSending: true));
    try {
      await sendCommandUseCase.call(0x03, event.minutes, 0x00);
      await sharedPreferences.setInt('sleepTime', event.minutes);
      emit(cur.copyWith(sleepTime: event.minutes, isSending: false));
    } catch (e) {
      emit(SettingError('Failed to set sleep time: $e'));
      emit(cur.copyWith(isSending: false));
    }
  }

  Future<void> _onChangeUnit(ChangeUnitEvent event, Emitter emit) async {
    final cur = state;
    if (cur is! SettingLoaded || _device == null) return;

    emit(cur.copyWith(isSending: true));
    try {
      await sendCommandUseCase.call(0x04, event.meters ? 1 : 0, 0x00);
      await sharedPreferences.setBool('unit', event.meters);
      emit(cur.copyWith(meters: event.meters, isSending: false));
    } catch (e) {
      emit(SettingError('Failed to set unit: $e'));
      emit(cur.copyWith(isSending: false));
    }
  }
}
