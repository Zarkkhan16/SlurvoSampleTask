abstract class ShotLibraryEvent  {}

class UpdateStartDate extends ShotLibraryEvent  {
  final DateTime startDate;
  UpdateStartDate(this.startDate);
}

class UpdateEndDate extends ShotLibraryEvent  {
  final DateTime endDate;
  UpdateEndDate(this.endDate);
}
class LoadAllShots extends ShotLibraryEvent {
  final String userUid;
  LoadAllShots(this.userUid);
}
class FilterShotsByDate extends ShotLibraryEvent {
  final DateTime startDate, endDate;
  FilterShotsByDate(this.startDate, this.endDate);
}
class ToggleShowFavorites extends ShotLibraryEvent  {}
class ToggleSessionFavorite extends ShotLibraryEvent {
  final String userUid;
  final String date;
  final int sessionNumber;
  final bool isFavorite;

  ToggleSessionFavorite({
    required this.userUid,
    required this.date,
    required this.sessionNumber,
    required this.isFavorite,
  });
}

class ClearFilters extends ShotLibraryEvent  {}

class ApplyFilters extends ShotLibraryEvent  {}
