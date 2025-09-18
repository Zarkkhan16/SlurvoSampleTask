import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:Slurvo/core/constants/app_images.dart';
import 'package:Slurvo/core/constants/app_strings.dart';

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

    final navHeight = screenWidth * 0.18; // ~18% of width
    final iconSize = screenWidth * 0.055; // ~5.5% of width
    final fontSize = screenWidth * 0.03; // ~3% of width

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        height: navHeight.clamp(65.0, 90.0),
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
            fontSize: fontSize.clamp(10.0, 14.0),
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: fontSize.clamp(10.0, 14.0),
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
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: iconSize.clamp(18.0, 28.0),
            width: iconSize.clamp(18.0, 28.0),
            fit: BoxFit.contain,
          ),
          SizedBox(height: iconSize * 0.05), // tiny spacing based on size
        ],
      ),
      label: label,
    );
  }
}
