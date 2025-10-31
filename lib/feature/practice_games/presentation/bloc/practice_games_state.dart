
class PracticeGamesState {
  final int selectedShots;
  final bool isCustomSelected;
  final List<String> players;
  final int currentAttempt;
  final int maxPlayers;

  PracticeGamesState({
    this.selectedShots = 3,
    this.isCustomSelected = false,
    this.players = const ["Elliot"],
    this.currentAttempt = 1,
    this.maxPlayers = 4,
  });

  PracticeGamesState copyWith({
    int? selectedShots,
    bool? isCustomSelected,
    List<String>? players,
    int? currentAttempt,
  }) {
    return PracticeGamesState(
      selectedShots: selectedShots ?? this.selectedShots,
      isCustomSelected: isCustomSelected ?? this.isCustomSelected,
      players: players ?? this.players,
      currentAttempt: currentAttempt ?? this.currentAttempt,
      maxPlayers: maxPlayers,
    );
  }

  bool get canAddPlayer => players.length < maxPlayers;
}