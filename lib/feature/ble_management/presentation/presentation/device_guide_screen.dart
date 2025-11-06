import 'package:flutter/material.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/session_view_button.dart';

class DeviceGuideScreen extends StatelessWidget {
  const DeviceGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: BottomNavBar(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            HeaderRow(
              headingName: "Step-By-Step Guide",
            ),
            SizedBox(height: 30),
            guideCard(
              text: "Turn on your A-ONE Precision Performance Launch Monitor",
            ),
            SizedBox(height: 20),
            guideCard(
              text: "Keep Bluetooth enable on your phone",
            ),
            SizedBox(height: 20),
            guideCard(
              text: "Scan for available devices nearby",
            ),
            SizedBox(height: 20),
            guideCard(
              text: "Select your device to initiate pairing",
            ),
            Spacer(),
            SessionViewButton(
              onSessionClick: () => Navigator.pop(context),
              buttonText: "Done",
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget guideCard({required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GradientBorderContainer(
        borderRadius: 16,
        borderWidth: 1,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("•  ", style: TextStyle(fontSize: 18, height: 1.2)),
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyle.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
