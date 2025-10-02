import 'package:flutter/material.dart';
import 'package:OneGolf/core/constants/app_colors.dart';
import 'package:OneGolf/core/constants/app_strings.dart';

class CustomizeBar extends StatelessWidget {
  const CustomizeBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final barHeight = screenHeight * 0.055; // ~5.5% of height
    final horizontalPadding = screenWidth * 0.04; // ~4% of width
    final fontSize = screenWidth * 0.04; // ~4% of width
    final iconSize = screenWidth * 0.055; // ~5.5% of width

    return Container(
      height: barHeight.clamp(40.0, 56.0),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.clamp(12.0, 20.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.searchBarBackground,
        borderRadius: BorderRadius.circular(barHeight / 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              AppStrings.customizeText,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: fontSize.clamp(14.0, 18.0),
                fontWeight: FontWeight.w400,
                height: 1.2,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.tune,
            color: AppColors.primaryText,
            size: iconSize.clamp(18.0, 26.0),
          ),
        ],
      ),
    );
  }
}
