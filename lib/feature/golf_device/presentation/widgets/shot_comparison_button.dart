import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_colors.dart';
class ShotComparisonButton extends StatelessWidget {
  const ShotComparisonButton({super.key, this.onTap, required this.headingText, this.svgAssetPath,});
  final VoidCallback? onTap;
  final String headingText;
  final String? svgAssetPath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.05;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(31),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (svgAssetPath != null) ...[
                SvgPicture.asset(
                  svgAssetPath!,
                  height: iconSize.clamp(16.0, 24.0),
                  width: iconSize.clamp(16.0, 24.0),
                  color: AppColors.primaryText,
                ),
                SizedBox(width: size.width * 0.02),
              ],
              Text(
                headingText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
