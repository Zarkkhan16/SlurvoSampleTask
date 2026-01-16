class DistanceCategory {
  final int id;
  final double min;
  final double max;

  const DistanceCategory({
    required this.id,
    required this.min,
    required this.max,
  });
}

const List<DistanceCategory> wedgeCategories = [
  DistanceCategory(id: 1, min: 40, max: 49),
  DistanceCategory(id: 2, min: 50, max: 59),
  DistanceCategory(id: 3, min: 60, max: 69),
  DistanceCategory(id: 4, min: 70, max: 79),
  DistanceCategory(id: 5, min: 80, max: 89),
  DistanceCategory(id: 6, min: 90, max: 99),
  DistanceCategory(id: 7, min: 100, max: 109),
  DistanceCategory(id: 8, min: 110, max: 119),
  DistanceCategory(id: 9, min: 120, max: 129),
];