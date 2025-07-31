import 'package:equatable/equatable.dart';

class ShotData extends Equatable {
  final String id;
  final double value;
  final String metric;
  final String unit;

  const ShotData({
    required this.id,
    required this.value,
    required this.metric,
    required this.unit,
  });

  @override
  List<Object> get props => [id, value, metric, unit];
}