class WedgeShot {
  final int categoryId;
  final double targetCarry;
  double? actualCarry;
  double? distanceFromTarget;
  int? score;

  WedgeShot({
    required this.categoryId,
    required this.targetCarry,
  });
}
