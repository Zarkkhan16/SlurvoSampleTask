class HandicapRule {
  final double minScore;
  final double maxScore;
  final String handicap;

  HandicapRule(this.minScore, this.maxScore, this.handicap);
}

List<HandicapRule> handicapRules = [
  HandicapRule(90, 100, '+6 to +2'),
  HandicapRule(85, 89, '+1 to +3'),
  HandicapRule(80, 84, '0 to 2'),
  HandicapRule(75, 79, '2 to 4'),
  HandicapRule(70, 74, '4 to 6'),
  HandicapRule(65, 69, '6 to 9'),
  HandicapRule(60, 64, '9 to 12'),
  HandicapRule(55, 59, '12 to 15'),
  HandicapRule(50, 54, '15 to 18'),
  HandicapRule(45, 49, '18 to 22'),
  HandicapRule(40, 44, '22 to 25'),
  HandicapRule(35, 39, '25 to 28'),
  HandicapRule(0, 34, '28+ / Beginner'),
];
