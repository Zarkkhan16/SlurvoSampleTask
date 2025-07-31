import 'package:flutter/material.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:Slurvo/core/constants/app_strings.dart';

class CustomizeBar extends StatelessWidget {
  const CustomizeBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.searchBarBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.customizeText,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.125,
              // 18px line-height / 16px font-size
              letterSpacing: 0,
            ),
            textAlign: TextAlign.left,
          ),
          Icon(Icons.tune, color: AppColors.primaryText),
        ],
      ),
    );
  }
}
