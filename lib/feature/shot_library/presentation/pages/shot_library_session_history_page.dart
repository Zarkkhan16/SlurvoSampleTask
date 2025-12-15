import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/shot_library/presentation/pages/shot_library_dispersion_page.dart';
import 'package:onegolf/feature/shots_history/presentation/pages/filter_screen.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/glassmorphism_card.dart';

import '../../../../core/constants/app_images.dart';
import '../../../choose_club_screen/model/club_model.dart';
import '../../../golf_device/data/model/shot_anaylsis_model.dart';
import '../../../golf_device/presentation/widgets/shot_comparison_button.dart';
import '../../../shots_history/presentation/pages/comparison_screen.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_bar.dart';
import '../../../widget/header_row.dart' show HeaderRow;

class ShotLibrarySessionHistoryPage extends StatefulWidget {
  final List<ShotAnalysisModel> sessionShots;

  const ShotLibrarySessionHistoryPage({super.key, required this.sessionShots});

  @override
  State<ShotLibrarySessionHistoryPage> createState() =>
      _ShotLibrarySessionHistoryPageState();
}

class _ShotLibrarySessionHistoryPageState
    extends State<ShotLibrarySessionHistoryPage> {
  int selectedIndex = 0;
  List<Club> selectedClubs = [];

  List<ShotAnalysisModel> get filteredShots {
    if (selectedClubs.isEmpty) return widget.sessionShots;
    return widget.sessionShots
        .where((shot) =>
            selectedClubs.any((c) => c.code == shot.clubName.toString()))
        .toList();
  }

  String _formatDate(String? date, String? time) {
    if (date == null || date.isEmpty) return '';
    try {
      final parsedDate = DateTime.parse(date);
      final formattedDate = DateFormat('MMM d').format(parsedDate);
      if (time != null && time.isNotEmpty) {
        final timeParts = time.split(':');
        if (timeParts.length >= 2) {
          final minutes = int.tryParse(timeParts[1]) ?? 0;
          return '$formattedDate • $minutes mins';
        }
      }
      return formattedDate;
    } catch (e) {
      return date;
    }
  }

  Future<void> _openFilterScreen(
    BuildContext context,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          selectedClubs: selectedClubs,
        ),
      ),
    );

    if (result != null && context.mounted) {
      setState(() {
        selectedClubs = List<Club>.from(result);
        // Reset selection if currently selected index is now out of bounds
        if (selectedIndex >= filteredShots.length) {
          selectedIndex = 0;
        }
      });
    } else {
      print('❌ No filter result or context not mounted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shots = filteredShots;
    final selectedShot = shots.isNotEmpty ? shots[selectedIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      bottomNavigationBar: const BottomNavBar(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        child: Column(
          children: [
            HeaderRow(
              headingName: "Session View",
              goScanScreen: false,
              onBackButton: () {
                Navigator.pop(context);
              },
            ),
            Text(
              _formatDate(selectedShot?.date, selectedShot?.sessionTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            _buildShotGrid(selectedShot),
            const SizedBox(height: 10),
            CustomizeBar(
              headingText: selectedClubs.isEmpty
                  ? 'Filter'
                  : 'Filter (${selectedClubs.length})',
              onPressed: () {
                _openFilterScreen(context);
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ShotComparisonButton(
                    headingText: "Shot Comparison",
                    svgAssetPath: AppImages.analysisIcon,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComparisonScreen(
                            shots: widget.sessionShots,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShotComparisonButton(
                    headingText: "Dispersion",
                    svgAssetPath: AppImages.groupIcon,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShotLibraryDispersionPage(
                            selectedShot: widget.sessionShots[selectedIndex],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTableHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 5, bottom: 20),
                  itemCount: shots.length,
                  itemBuilder: (context, index) {
                    final shot = shots[index];
                    final isSelected = index == selectedIndex;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            // Club, shot number etc...
                            Row(
                              children: [
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.cardBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStrings.getClub(shot.clubName),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  ' ${shot.shotNumber.toString()}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            _buildDataCell(
                                shot.clubSpeed.toStringAsFixed(1), isSelected,
                                flex: 1),
                            _buildDataCell(
                                shot.ballSpeed.toStringAsFixed(1), isSelected,
                                flex: 1),
                            _buildDataCell(
                                shot.smashFactor.toStringAsFixed(2), isSelected,
                                flex: 1),
                            _buildDataCell(
                                shot.carryDistance.toStringAsFixed(1),
                                isSelected,
                                flex: 1),
                            _buildDataCell(
                                shot.totalDistance.toStringAsFixed(1),
                                isSelected,
                                flex: 1),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotGrid(ShotAnalysisModel? shot) {
    if (shot == null) return const SizedBox();
    final metrics = [
      {
        "metric": "Club Speed",
        "value": shot.clubSpeed.toStringAsFixed(1),
        "unit": "MPH"
      },
      {
        "metric": "Ball Speed",
        "value": shot.ballSpeed.toStringAsFixed(1),
        "unit": "MPH"
      },
      {
        "metric": "Carry Distance",
        "value": shot.carryDistance.toStringAsFixed(1),
        "unit": "YDS"
      },
      {
        "metric": "Smash Factor",
        "value": shot.smashFactor.toStringAsFixed(2),
        "unit": ""
      },
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 10,
        childAspectRatio: MediaQuery.of(context).size.width / 210,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GlassmorphismCard(
          value: metrics[index]["value"]!,
          name: metrics[index]["metric"]!,
          unit: metrics[index]["unit"]!,
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          _buildHeaderCell('Shot', '#', flex: 1),
          _buildHeaderCell('Club\nSpeed', 'mph', flex: 1),
          _buildHeaderCell('Ball\nSpeed', 'mph', flex: 1),
          _buildHeaderCell('Smash\nFactor', '', flex: 1),
          _buildHeaderCell('Carry\nDistance', 'yds', flex: 1),
          _buildHeaderCell('Total\nDistance', 'yds', flex: 1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, String subTitle, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(
            text,
            style: AppTextStyle.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subTitle,
            style: AppTextStyle.roboto(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppColors.unselectedIcon,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, bool isSelected, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
