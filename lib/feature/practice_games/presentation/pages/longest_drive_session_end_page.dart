import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/glassmorphism_card.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/header_row.dart';
import '../../../widget/session_view_button.dart';
import '../widgets/metric_display.dart';

class LongestDriveSessionEndPage extends StatelessWidget {
  LongestDriveSessionEndPage({super.key});

  final allMetrics = [
    {
      "metric": "Total Distance",
      "value": "0.00",
      "unit": "YDS"
    },
    {
      "metric": "Ball Speed",
      "value": "0.00",
      "unit": "MPH"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          children: [
            HeaderRow(
              headingName: "Longest Drive",
            ),
            SizedBox(height: 10),
            Image.asset(AppImages.trophyImage),
            MetricDisplay(value: "0.00", label: "Carry Distance", unit: "YDS"),
            GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 40,
                childAspectRatio: 1.42,
              ),
              itemCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GlassmorphismCard(
                  value: allMetrics[index]["value"]!,
                  name: allMetrics[index]["metric"]!,
                  unit: allMetrics[index]["unit"]!,
                );
              },
            ),
            const Spacer(),
            SessionViewButton(
              onSessionClick: () {
                Navigator.pop(context);
              },
              buttonText: "Start New",
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
