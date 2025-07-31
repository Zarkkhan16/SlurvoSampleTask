import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sample_task/core/constants/app_colors.dart';
import 'package:sample_task/core/constants/app_images.dart';
import 'package:sample_task/core/constants/app_strings.dart';

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
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        height: 78,
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
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            _buildBarItem(AppImages.homeIcon, AppStrings.homePageLabel),
            _buildBarItem(AppImages.shotAnalysisIcon, AppStrings.shotAnalysisLabel),
            _buildBarItem(AppImages.practiceGamesIcon, AppStrings.practiceGamesLabel),
            _buildBarItem(AppImages.libraryIcon, AppStrings.shotLibraryLabel),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBarItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 22,
            width: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 1),
        ],
      ),
      label: label,
    );
  }
}
