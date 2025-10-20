abstract class SettingState {}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingLoaded extends SettingState {
  final bool backlight;
  final int sleepTime;
  final bool meters;
  final bool isSending;

  SettingLoaded({
    required this.backlight,
    required this.sleepTime,
    required this.meters,
    this.isSending = false,
  });

  SettingLoaded copyWith({
    bool? backlight,
    int? sleepTime,
    bool? meters,
    bool? isSending,
  }) {
    return SettingLoaded(
      backlight: backlight ?? this.backlight,
      sleepTime: sleepTime ?? this.sleepTime,
      meters: meters ?? this.meters,
      isSending: isSending ?? this.isSending,
    );
  }
}

class SettingError extends SettingState {
  final String message;
  SettingError(this.message);
}
