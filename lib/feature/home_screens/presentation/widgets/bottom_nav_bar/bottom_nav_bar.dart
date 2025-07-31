import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sample_task/core/constants/app_colors.dart';
import 'package:sample_task/core/constants/app_images.dart';
import 'package:sample_task/core/constants/app_strings.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          backgroundColor: AppColors.bottomNavBackground,
          selectedItemColor: AppColors.primaryText,
          unselectedItemColor: AppColors.unselectedIcon,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 12),
          showUnselectedLabels: true,
          items:  [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset(AppImages.homeIcon, height: 24, width: 22),
              ),
              label: AppStrings.homePageLabel,
            ),
            BottomNavigationBarItem(
              icon:  Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child:SvgPicture.asset(AppImages.shotAnalysisIcon, height: 24, width: 22),),
              label: AppStrings.shotAnalysisLabel,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset(AppImages.practiceGamesIcon,  height: 24, width: 22),
              ),
              label: AppStrings.practiceGamesLabel,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset(AppImages.libraryIcon,  height: 24, width: 22),
              ),
              label: AppStrings.shotLibraryLabel,

            ),
          ],
        ),
      ),
    );
  }
}
