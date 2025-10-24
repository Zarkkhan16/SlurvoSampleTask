import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';

class CustomizeBar extends StatelessWidget {
  final VoidCallback onPressed;
  final String headingText;

  const CustomizeBar({super.key, required this.onPressed, this.headingText = AppStrings.customizeText});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final barHeight = screenHeight * 0.055;
    final horizontalPadding = screenWidth * 0.04;
    final fontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.055;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: barHeight.clamp(40.0, 56.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(barHeight / 2),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(128, 128, 128, 1.0),
              Color.fromRGBO(128, 128, 128, 0.05),
              Color.fromRGBO(128, 128, 128, 0.3),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(1),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding.clamp(12.0, 20.0),
          ),
          decoration: BoxDecoration(
            color: AppColors.searchBarBackground,
            borderRadius: BorderRadius.circular((barHeight / 2) - 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  headingText,
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
        ),
      ),
    );
  }
}
