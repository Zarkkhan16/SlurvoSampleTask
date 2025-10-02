import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:OneGolf/core/constants/app_colors.dart';
import 'package:OneGolf/core/constants/app_images.dart';
import 'package:OneGolf/core/constants/app_strings.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = (screenWidth * 0.055).clamp(20.0, 28.0);
    final fontSize = (screenWidth * 0.03).clamp(10.0, 14.0);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        color: AppColors.bottomNavBackground,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: fontSize,
          ),
          items: [
            _buildBarItem(AppImages.homeIcon, AppStrings.homePageLabel, iconSize),
            _buildBarItem(AppImages.shotAnalysisIcon, AppStrings.shotAnalysisLabel, iconSize),
            _buildBarItem(AppImages.practiceGamesIcon, AppStrings.practiceGamesLabel, iconSize),
            _buildBarItem(AppImages.libraryIcon, AppStrings.shotLibraryLabel, iconSize),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBarItem(String iconPath, String label, double iconSize) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        height: iconSize,
        width: iconSize,
        fit: BoxFit.contain,
      ),
      label: label,
    );
  }
}
