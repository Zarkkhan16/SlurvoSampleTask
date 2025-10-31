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

class ResetSessionEvent extends PracticeGamesEvent {}