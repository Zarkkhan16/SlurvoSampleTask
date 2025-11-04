import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:onegolf/feature/widget/header_row.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/gradient_border_container.dart';

class DeviceConnectedScreen extends StatelessWidget {
  const DeviceConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            HeaderRow(
              headingName: "Connect Status",
            ),
            SizedBox(height: 20),
            GradientBorderContainer(
              borderRadius: 16,
              borderWidth: 1,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppImages.connectedIcon,
                    height: 50,
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Connected",
                        style: AppTextStyle.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Ready to Track Shots",
                        style: AppTextStyle.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Connected",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildItem("Is your device powered on?", true),
                  _buildItem("Is Bluetooth enable?", true),
                  _buildItem("Is the device in range?", true),
                  _buildItem("Try restarting your phone or device", false,
                      isLoading: true),
                  const SizedBox(height: 20),
                  const Text(
                    "View Supported Devices",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text.rich(
                    TextSpan(
                      text: "Need help connecting? ",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Step-by-step guide",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String text, bool isChecked, {bool isLoading = false}) {
    IconData icon;
    Color iconColor;

    if (isLoading) {
      icon = Icons.refresh;
      iconColor = Colors.green;
    } else if (isChecked) {
      icon = Icons.check;
      iconColor = Colors.green;
    } else {
      icon = Icons.close;
      iconColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
