abstract class WedgeCombineEvent {}

class WedgeCombineStartedEvent extends WedgeCombineEvent {}

class BleDataReceivedEvent extends WedgeCombineEvent {
  final List<int> data;
  BleDataReceivedEvent(this.data);
}
class MoveToNextShotEvent extends WedgeCombineEvent {}
class FinishSessionEvent extends WedgeCombineEvent {}
class ResetWedgeCombineEvent extends WedgeCombineEvent {}
