abstract class PracticeGamesEvent {}

class SelectShotsEvent extends PracticeGamesEvent {
  final int shots;
  SelectShotsEvent(this.shots);
}

class SelectCustomEvent extends PracticeGamesEvent {}

class UpdateCustomShotsEvent extends PracticeGamesEvent {
  final String value;
  UpdateCustomShotsEvent(this.value);
}

class AddPlayerEvent extends PracticeGamesEvent {}

class NextAttemptEvent extends PracticeGamesEvent {}
class SessionEndAttemptEvent extends PracticeGamesEvent {}

class ResetSessionEvent extends PracticeGamesEvent {}

class StartListeningToBleDataEvent extends PracticeGamesEvent {}

/// Stop listening to BLE notifications
class StopListeningToBleDataEvent extends PracticeGamesEvent {}

/// Send command/packet to BLE device
class SendBleCommandEvent extends PracticeGamesEvent {
  final List<int> command;

  SendBleCommandEvent(this.command);

  @override
  List<Object?> get props => [command];
}

/// BLE data received from device
class BleDataReceivedEvent extends PracticeGamesEvent {
  final List<int> data;

  BleDataReceivedEvent(this.data);

  @override
  List<Object?> get props => [data];
}
