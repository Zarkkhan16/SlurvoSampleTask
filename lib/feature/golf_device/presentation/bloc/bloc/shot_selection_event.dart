abstract class ShotSelectionEvent {}

class SelectShotEvent extends ShotSelectionEvent {
  final int index;
  SelectShotEvent(this.index);
}

class LoadInitialShotEvent extends ShotSelectionEvent {}