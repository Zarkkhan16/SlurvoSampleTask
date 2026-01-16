
import 'package:onegolf/feature/combine_test/domain/entities/wedge_shot.dart';

class WedgeCombineState {
  final List<WedgeShot> shots;
  final int currentIndex;
  final double projectedScore;
  final bool isFinished;
  final bool shotJustPlayed;

  WedgeCombineState({
    required this.shots,
    required this.currentIndex,
    required this.projectedScore,
    this.isFinished = false,
    this.shotJustPlayed = false,
  });

  WedgeShot get currentShot => shots[currentIndex];
}
