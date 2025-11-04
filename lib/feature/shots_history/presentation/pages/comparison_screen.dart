import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/golf_device/data/model/shot_anaylsis_model.dart';
import 'package:onegolf/feature/shots_history/presentation/pages/view_comparison_screen.dart';

import '../../../widget/session_view_button.dart';
class ComparisonScreen extends StatefulWidget {
  final List<ShotAnalysisModel> shots;
  const ComparisonScreen({
    super.key,
    required this.shots,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  ShotAnalysisModel? primaryShot;

  @override
  Widget build(BuildContext context) {
    if (widget.shots.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: CustomAppBar(),
        bottomNavigationBar: BottomNavBar(),
        body: const Center(
          child: Text('No shots available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        child: Column(
          children: [
            HeaderRow(headingName: "Shot Comparison"),
            const SizedBox(height: 10),
            _buildSectionTitle("Select Primary Shot"),
            const SizedBox(height: 15),
            Expanded(
              child: _buildShotSelectionTable(
                shots: widget.shots,
                selectedShot: primaryShot,
                onShotSelected: (shot) {
                  setState(() {
                    primaryShot = shot;
                  });
                },
              ),
            ),
            const SizedBox(height: 25),
            SessionViewButton(
                onSessionClick: primaryShot != null ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComparisonShotSelectionScreen(
                        shots: widget.shots,
                        primaryShot: primaryShot!,
                      ),
                    ),
                  );
                } : null,
                buttonText: 'Choose Comparison Shot',
              textColor: primaryShot != null ? AppColors.buttonText : Colors.grey,
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        title,
        style: AppTextStyle.roboto(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildShotSelectionTable({
    required List<ShotAnalysisModel> shots,
    required ShotAnalysisModel? selectedShot,
    required Function(ShotAnalysisModel) onShotSelected,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 5, bottom: 15),
                itemCount: shots.length,
                itemBuilder: (context, index) {
                  final shot = shots[index];
                  final isSelected = selectedShot?.shotNumber == shot.shotNumber;

                  return InkWell(
                    onTap: () => onShotSelected(shot),
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: index == shots.length - 1 ? 10 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
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
                            shot.clubSpeed.toStringAsFixed(1),
                            isSelected,
                            flex: 1,
                          ),
                          _buildDataCell(
                            shot.ballSpeed.toStringAsFixed(1),
                            isSelected,
                            flex: 1,
                          ),
                          _buildDataCell(
                            shot.smashFactor.toStringAsFixed(1),
                            isSelected,
                            flex: 1,
                          ),
                          _buildDataCell(
                            shot.carryDistance.toStringAsFixed(1),
                            isSelected,
                            flex: 1,
                          ),
                          _buildDataCell(
                            shot.totalDistance.toStringAsFixed(1),
                            isSelected,
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
          _buildHeaderCell('Smash\nFactor', 'rmp', flex: 1),
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
          if (subTitle.isNotEmpty)
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

  Widget _buildDataCell(
      String text,
      bool isSelected, {
        required int flex,
      }) {
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

class ComparisonShotSelectionScreen extends StatefulWidget {
  final List<ShotAnalysisModel> shots;
  final ShotAnalysisModel primaryShot;

  const ComparisonShotSelectionScreen({
    super.key,
    required this.shots,
    required this.primaryShot,
  });

  @override
  State<ComparisonShotSelectionScreen> createState() =>
      _ComparisonShotSelectionScreenState();
}

class _ComparisonShotSelectionScreenState
    extends State<ComparisonShotSelectionScreen> {
  ShotAnalysisModel? comparisonShot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        child: Column(
          children: [
            HeaderRow(headingName: "Shot Comparison"),
            const SizedBox(height: 10),
            _buildSectionTitle("Select Comparison Shot"),
            const SizedBox(height: 15),
            Expanded(
              child: _buildShotSelectionTable(
                shots: widget.shots,
                selectedShot: comparisonShot,
                disabledShot: widget.primaryShot,
                onShotSelected: (shot) {
                  setState(() {
                    comparisonShot = shot;
                  });
                },
              ),
            ),
            const SizedBox(height: 25),

              SessionViewButton(
                onSessionClick: comparisonShot != null ?() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewComparisonScreen(
                        primaryShot: widget.primaryShot,
                        comparisonShot: comparisonShot!,
                      ),
                    ),
                  );
                } : null,
                buttonText: 'View Comparison',
                textColor: comparisonShot !=null ? AppColors.buttonText : Colors.grey,
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        title,
        style: AppTextStyle.roboto(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildShotSelectionTable({
    required List<ShotAnalysisModel> shots,
    required ShotAnalysisModel? selectedShot,
    required ShotAnalysisModel? disabledShot,
    required Function(ShotAnalysisModel) onShotSelected,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 5, bottom: 15),
                itemCount: shots.length,
                itemBuilder: (context, index) {
                  final shot = shots[index];
                  final isSelected = selectedShot?.shotNumber == shot.shotNumber;
                  final isDisabled = disabledShot?.shotNumber == shot.shotNumber;

                  return InkWell(
                    onTap: isDisabled ? null : () => onShotSelected(shot),
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: index == shots.length - 1 ? 10 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? Colors.grey.shade300
                            : (isSelected ? Colors.black : Colors.transparent),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: isDisabled
                                      ? Colors.grey.shade400
                                      : (isSelected
                                      ? Colors.white
                                      : AppColors.cardBackground),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    AppStrings.getClub(shot.clubName),
                                    style: TextStyle(
                                      color: isDisabled
                                          ? Colors.grey.shade600
                                          : (isSelected
                                          ? Colors.black
                                          : Colors.white),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                ' ${shot.shotNumber.toString()}',
                                style: TextStyle(
                                  color: isDisabled
                                      ? Colors.grey.shade600
                                      : (isSelected
                                      ? Colors.white
                                      : Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          _buildDataCell(
                            shot.clubSpeed.toStringAsFixed(1),
                            isSelected,
                            isDisabled,
                            flex: 1,
                          ),
                          _buildDataCell(
                            shot.ballSpeed.toStringAsFixed(1),
                            isSelected,
                            isDisabled,
                            flex: 1,
                          ),
                          _buildDataCell(
                            shot.smashFactor.toStringAsFixed(1),
                            isSelected,
                            isDisabled,
                            flex: 1,
                          ),
                          _buildDataCell(
                            shot.carryDistance.toStringAsFixed(1),
                            isSelected,
                            isDisabled,
                            flex: 1,
                          ),
                          _buildDataCell(
                            shot.totalDistance.toStringAsFixed(1),
                            isSelected,
                            isDisabled,
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
          _buildHeaderCell('Smash\nFactor', 'rmp', flex: 1),
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
          if (subTitle.isNotEmpty)
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

  Widget _buildDataCell(
      String text,
      bool isSelected,
      bool isDisabled, {
        required int flex,
      }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: isDisabled
              ? Colors.grey.shade600
              : (isSelected ? Colors.white : Colors.black),
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}