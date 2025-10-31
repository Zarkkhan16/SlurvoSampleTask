import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../choose_club_screen/model/club_model.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/header_row.dart';

class FilterScreen extends StatefulWidget {
  final List<Club> selectedClubs;

  const FilterScreen({
    super.key,
    this.selectedClubs = const [],
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<Club> clubs = [];
  late List<Club> selectedClubs;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    selectedClubs = widget.selectedClubs
        .map((club) => Club(code: club.code, name: club.name))
        .toList();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final fetchedClubs = [
      Club(code: "0", name: "1 Wood"),
      Club(code: "1", name: "2 Wood"),
      Club(code: "2", name: "3 Wood"),
      Club(code: "3", name: "5 Wood"),
      Club(code: "4", name: "7 Wood"),
      Club(code: "5", name: "2 Hybrid"),
      Club(code: "6", name: "3 Hybrid"),
      Club(code: "7", name: "4 Hybrid"),
      Club(code: "8", name: "5 Hybrid"),
      Club(code: "9", name: "1 Iron"),
      Club(code: "10", name: "2 Iron"),
      Club(code: "11", name: "3 Iron"),
      Club(code: "12", name: "4 Iron"),
      Club(code: "13", name: "5 Iron"),
      Club(code: "14", name: "6 Iron"),
      Club(code: "15", name: "7 Iron"),
      Club(code: "16", name: "8 Iron"),
      Club(code: "17", name: "9 Iron"),
      Club(code: "18", name: "Pitching Wedge"),
      Club(code: "19", name: "50 Wedge"),
      Club(code: "20", name: "52 Wedge"),
      Club(code: "21", name: "54 Wedge"),
      Club(code: "22", name: "56 Wedge"),
      Club(code: "23", name: "58 Wedge"),
      Club(code: "24", name: "60 Wedge"),
    ];

    setState(() {
      clubs = fetchedClubs;
      isLoading = false;
    });
  }

  void _toggleClubSelection(Club club) {
    setState(() {
      final index = selectedClubs.indexWhere((c) => c.code == club.code);
      if (index != -1) {
        selectedClubs.removeAt(index);
        print('🔴 Removed: ${club.name} (${club.code})');
      } else {
        selectedClubs.add(club);
        print('🟢 Added: ${club.name} (${club.code})');
      }
      print(
          '📋 Currently selected: ${selectedClubs.map((c) => c.name).join(", ")}');
    });
  }

  void _clearAllFilters() {
    setState(() {
      selectedClubs.clear();
      print('🧹 Cleared all filters');
    });
  }

  void _applyFilters() {
    print(
        '✅ Applying filters: ${selectedClubs.map((c) => '${c.name} (${c.code})').join(", ")}');
    final result = selectedClubs
        .map((club) => Club(code: club.code, name: club.name))
        .toList();
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: const BottomNavBar(),
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: HeaderRow(
              headingName: 'Filter by Club',
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildBody(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _applyFilters();
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(31),
                  ),
                  child: Center(
                    child: Text(
                      selectedClubs.isEmpty ? 'Show All Shots' : 'Apply Filter',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.white)),
      );
    }
    final woods = clubs.where((c) => c.name.contains("Wood")).toList();
    final hybrids = clubs.where((c) => c.name.contains("Hybrid")).toList();
    final irons = clubs.where((c) => c.name.contains("Iron")).toList();
    final wedges = clubs.where((c) => c.name.contains("Wedge")).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategory("WOODS", woods),
          const SizedBox(height: 20),
          _buildCategory("HYBRIDS", hybrids),
          const SizedBox(height: 20),
          _buildCategory("IRONS", irons),
          const SizedBox(height: 20),
          _buildCategory("WEDGES", wedges),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<Club> categoryClubs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categoryClubs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 4,
          ),
          itemBuilder: (context, index) {
            final club = categoryClubs[index];
            final isSelected = selectedClubs.any((c) => c.code == club.code);

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _toggleClubSelection(club);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(128, 128, 128, 1.0),
                      Color.fromRGBO(128, 128, 128, 0.05),
                      Color.fromRGBO(128, 128, 128, 0.3),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryText : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child: Text(
                      club.name,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
