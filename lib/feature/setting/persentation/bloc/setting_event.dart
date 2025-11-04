abstract class SettingEvent {}

class LoadSettingsEvent extends SettingEvent {
  final bool initialUnit;
  LoadSettingsEvent({required this.initialUnit});
}

class ToggleBacklightEvent extends SettingEvent {
  final bool enabled;
  ToggleBacklightEvent(this.enabled);
}

class UpdateSleepTimeLocally extends SettingEvent {
  final int newValue;
  UpdateSleepTimeLocally(this.newValue);
}

class SendSleepTimeCommandEvent extends SettingEvent {
  final int minutes;
  SendSleepTimeCommandEvent(this.minutes);
}

class ChangeUnitEvent extends SettingEvent {
  final bool meters;
  ChangeUnitEvent(this.meters);
}
