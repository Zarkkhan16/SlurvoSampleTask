import 'dart:math';
import 'distance_category.dart';
import 'wedge_shot.dart';

List<WedgeShot> generateAllShots() {
  final random = Random();
  final List<WedgeShot> shots = [];

  for (final category in wedgeCategories) {
    for (int i = 0; i < 6; i++) {
      final value =
          category.min + random.nextDouble() * (category.max - category.min);

      shots.add(
        WedgeShot(
          categoryId: category.id,
          targetCarry: double.parse(value.toStringAsFixed(1)),
        ),
      );
    }
  }

  shots.shuffle();
  return shots;
}

int calculateShotScore(double deviation) {
  final d = deviation.abs();

  if (d <= 1) return 100;
  if (d <= 2) return 95;
  if (d <= 3) return 90;
  if (d <= 4) return 85;
  if (d <= 5) return 80;
  if (d <= 6) return 75;
  if (d <= 7) return 70;
  if (d <= 8) return 65;
  if (d <= 10) return 60;
  if (d <= 12) return 50;
  if (d <= 15) return 40;
  if (d <= 20) return 30;
  if (d <= 25) return 20;
  if (d <= 30) return 10;
  return 0;
}
