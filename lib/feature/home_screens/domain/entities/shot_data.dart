import 'package:equatable/equatable.dart';

class ShotData extends Equatable {
   String? id = '';
  final dynamic value;
  final String metric;
  final String unit;

  ShotData({
    this.id,
    required this.value,
    required this.metric,
    required this.unit,
  });

  @override
  List<Object> get props => [id ?? "", value, metric, unit];
}

class ShotDataNew {
  final String metric;
  final dynamic value;
  final String unit;
  final String? displayValue;

  ShotDataNew({
    required this.metric,
    required this.value,
    required this.unit,
    this.displayValue,
  });

  @override
  String toString() {
    return 'ShotData{metric: $metric, value: $value, unit: $unit}';
  }
}