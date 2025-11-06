import 'package:equatable/equatable.dart';

class ClubEntity extends Equatable {
  final String id; // Internal ID (e.g., "pw", "driver", "3w")
  final String name; // Display name (e.g., "Pitching Wedge", "Driver", "3 Wood")
  final ClubCategory category;
  final int clubId; // ✅ Numeric ID for BLE packet (0, 1, 2, 3, ...)
  final bool isSelected;

  const ClubEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.clubId, // ✅ Required numeric ID
    this.isSelected = false,
  });

  ClubEntity copyWith({
    String? id,
    String? name,
    ClubCategory? category,
    int? clubId,
    bool? isSelected,
  }) {
    return ClubEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      clubId: clubId ?? this.clubId,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [id, name, category, clubId, isSelected];
}

enum ClubCategory {
  woods,
  hybrids,
  irons,
  wedges,
}