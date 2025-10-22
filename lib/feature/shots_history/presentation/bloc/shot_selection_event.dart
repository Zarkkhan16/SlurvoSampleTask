import 'package:equatable/equatable.dart';

abstract class ShotHistoryEvent extends Equatable {
  const ShotHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadShotHistoryEvent extends ShotHistoryEvent {
  const LoadShotHistoryEvent();
}

class SelectShotEvent extends ShotHistoryEvent {
  final int index;

  const SelectShotEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class LoadInitialShotEvent extends ShotHistoryEvent {
  const LoadInitialShotEvent();
}
class ClearRecordEvent extends ShotHistoryEvent {
  const ClearRecordEvent();
}
class ClearRecordResponseReceivedEvent extends ShotHistoryEvent {
  const ClearRecordResponseReceivedEvent();
}