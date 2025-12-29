import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/combine_test/games/full_combine_test/presentation/pages/full_combine_summary_page.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/pages/wedge_combine_summary_page.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/custom_score_bar.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class FullCombineStartPage extends StatelessWidget {
  const FullCombineStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // bottomNavigationBar: BottomNavBar(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          children: [
            HeaderRow(headingName: "Full Combine Test"),
            Text(
              "Test. Score. Improve",
              style: AppTextStyle.roboto(),
            ),
            SizedBox(height: 10),
            GradientBorderContainer(
              borderRadius: 16,
              padding: EdgeInsets.symmetric(vertical: 20),
              containerWidth: double.infinity,
              child: Column(
                children: [
                  Text(
                    'Target Carry',
                    style: AppTextStyle.roboto(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "100.0",
                    style: AppTextStyle.oswald(
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    'yds',
                    style: AppTextStyle.roboto(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GradientBorderContainer(
              borderRadius: 16,
              padding: EdgeInsets.symmetric(vertical: 20),
              containerWidth: double.infinity,
              child: Column(
                children: [
                  Text(
                    'Actual Carry',
                    style: AppTextStyle.roboto(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "0.0",
                    style: AppTextStyle.oswald(
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    'yds',
                    style: AppTextStyle.roboto(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GradientBorderContainer(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  containerHeight: 123,
                  containerWidth: 176,
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "- 0.0",
                        style: AppTextStyle.oswald(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Distance From Target",
                        style: AppTextStyle.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "YDS",
                        style: AppTextStyle.roboto(
                          fontSize: 16,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                GradientBorderContainer(
                  containerHeight: 123,
                  containerWidth: 176,
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "- 0.0",
                        style: AppTextStyle.oswald(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Shot Score",
                        style: AppTextStyle.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "PTS",
                        style: AppTextStyle.roboto(
                          fontSize: 16,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Projected Score",
              style: AppTextStyle.roboto(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            CustomScoreBar(
              value: 0.0,
              textStyle: AppTextStyle.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.buttonText,
              ),
              min: 0.0,
              max: 100.0,
              height: 24,
            ),
            SizedBox(height: 20),
            SessionViewButton(
              onSessionClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullCombineSummaryPage(),
                  ),
                );
              },
              buttonText: "Finish Session",
            ),
          ],
        ),
      ),
    );
  }
}
