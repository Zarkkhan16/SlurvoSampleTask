import 'package:flutter/material.dart';
import 'package:sample_task/core/constants/app_colors.dart';
import 'package:sample_task/feature/home_screens/presentation/pages/body/shot_analysis_body.dart';
import 'package:sample_task/feature/home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:sample_task/feature/home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';

class ShotAnalysisPage extends StatelessWidget {
  const ShotAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: const BottomNavBar(),
      appBar: const CustomAppBar(),
      body: ShotAnalysisBody(),
    );
  }
}
