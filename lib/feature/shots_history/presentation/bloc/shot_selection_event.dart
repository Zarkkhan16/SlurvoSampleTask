import 'package:equatable/equatable.dart';

import '../../../choose_club_screen/model/club_model.dart';

abstract class ShotHistoryEvent extends Equatable {
  const ShotHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadShotHistoryEvent extends ShotHistoryEvent {
  final int sessionNumber;
  const LoadShotHistoryEvent({required this.sessionNumber});
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
  final int sessionNumber;
  const ClearRecordEvent({required this.sessionNumber});
}
class ClearRecordResponseReceivedEvent extends ShotHistoryEvent {
  final int sessionNumber;
  const ClearRecordResponseReceivedEvent({required this.sessionNumber});
}

class UpdateFilterEvent extends ShotHistoryEvent {
  final List<Club> selectedClubs;

  const UpdateFilterEvent(this.selectedClubs);

  @override
  List<Object?> get props => [selectedClubs];
}