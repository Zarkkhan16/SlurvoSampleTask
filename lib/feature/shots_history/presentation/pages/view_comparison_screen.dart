import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../golf_device/data/model/shot_anaylsis_model.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/glassmorphism_card.dart';
import '../../../widget/custom_app_bar.dart';

class ViewComparisonScreen extends StatelessWidget {
  final ShotAnalysisModel primaryShot;
  final ShotAnalysisModel comparisonShot;

  const ViewComparisonScreen({
    super.key,
    required this.primaryShot,
    required this.comparisonShot,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,),
        child: Column(
          children: [
            HeaderRow(headingName: "Shot Comparison"),
            _buildShotSection("Primary Shot", primaryShot),
            const SizedBox(height: 15),
            Divider(color: AppColors.dividerColor, thickness: 2),
            _buildShotSection("Comparison Shot", comparisonShot),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildShotSection(String title, ShotAnalysisModel shot) {
    final metrics = [
      {
        "metric": "Ball Speed",
        "value": shot.ballSpeed.toStringAsFixed(1),
        "unit": "MPH"
      },
      {
        "metric": "Club Speed",
        "value": shot.clubSpeed.toStringAsFixed(1),
        "unit": "MPH"
      },
      {
        "metric": "Carry Distance",
        "value": shot.carryDistance.toStringAsFixed(1),
        "unit": "YDS"
      },
      {
        "metric": "Smash Factor",
        "value": shot.smashFactor.toStringAsFixed(1),
        "unit": ""
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.roboto(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 5),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 35,
            mainAxisSpacing: 15,
            childAspectRatio: 1.48,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return GlassmorphismCard(
              value: metrics[index]["value"]!,
              name: metrics[index]["metric"]!,
              unit: metrics[index]["unit"]!,
            );
          },
        ),
      ],
    );
  }
}