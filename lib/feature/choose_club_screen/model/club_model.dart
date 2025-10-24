import 'package:equatable/equatable.dart';

class Club extends Equatable {
  final String code;
  final String name;

  const Club({
    required this.code,
    required this.name,
  });

  @override
  List<Object?> get props => [code, name];

  // For JSON serialization if needed
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
}