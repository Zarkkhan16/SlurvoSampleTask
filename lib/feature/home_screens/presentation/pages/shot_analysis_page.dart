import 'package:flutter/material.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:Slurvo/feature/home_screens/presentation/pages/body/shot_analysis_body.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';

class ShotAnalysisPage extends StatelessWidget {
  DiscoveredDevice? connectedDevice;
  ShotAnalysisPage({super.key, required this.connectedDevice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: const BottomNavBar(),
      appBar: const CustomAppBar(),
      body: ShotAnalysisBody(connectedDevice: connectedDevice,),
    );
  }
}
