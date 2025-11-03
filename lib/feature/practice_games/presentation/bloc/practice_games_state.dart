
import '../../../../core/constants/app_strings.dart';
import '../../../golf_device/domain/entities/golf_data_entities.dart';

class PracticeGamesState {
  final int selectedShots;
  final bool isCustomSelected;
  final List<String> players;
  final int currentAttempt;
  final int maxPlayers;
  final bool isListeningToBle;
  final List<GolfDataEntity> latestBleData;
  final GolfDataEntity bestShot;
  final String? bleError;
  PracticeGamesState({
    this.selectedShots = 3,
    this.isCustomSelected = false,
    List<String>? players,
    this.currentAttempt = 1,
    this.maxPlayers = 4,

    this.isListeningToBle = false,
    this.latestBleData = const [],
    this.bleError,
    this.bestShot = const GolfDataEntity(
      recordNumber: 0,
      ballSpeed: 0.00,
      carryDistance: 0.00,
      clubName: 0,
      clubSpeed: 0.00,
      totalDistance: 0.00,
      battery: 0,
    ),
  }): players = players ?? [AppStrings.userProfileData.name];

  PracticeGamesState copyWith({
    int? selectedShots,
    bool? isCustomSelected,
    List<String>? players,
    int? currentAttempt,

    bool? isListeningToBle,
    List<GolfDataEntity>? latestBleData,
    String? bleError,
    GolfDataEntity? bestShot,
  }) {
    return PracticeGamesState(
      selectedShots: selectedShots ?? this.selectedShots,
      isCustomSelected: isCustomSelected ?? this.isCustomSelected,
      players: players ?? this.players,
      currentAttempt: currentAttempt ?? this.currentAttempt,
      maxPlayers: maxPlayers,

      isListeningToBle: isListeningToBle ?? this.isListeningToBle,
      latestBleData: latestBleData ?? this.latestBleData,
      bleError: bleError,
      bestShot: bestShot ?? this.bestShot,
    );
  }

  bool get canAddPlayer => players.length < maxPlayers;

  bool get hasBleData => latestBleData.isNotEmpty;
  bool get hasBleError => bleError != null;
}