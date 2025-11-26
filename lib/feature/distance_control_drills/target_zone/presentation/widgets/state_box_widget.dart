import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';

class StatBoxWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool isGreen, showColor;
  final bool showTargetTolerance;
  final String toleranceValue;
  final bool showYdsDown;

  const StatBoxWidget({
    super.key,
    required this.label,
    required this.value,
    this.isGreen = false,
    this.showColor = false,
    this.showTargetTolerance = true,
    this.toleranceValue = '',
    this.showYdsDown = false,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 20,
      containerWidth: double.infinity,
      backgroundColor: showColor
          ? isGreen
              ? AppColors.green
              : AppColors.red
          : const Color(0xFF2A2A2A),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyle.roboto(
              color: AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: AppTextStyle.oswald(fontSize: 35),
          ),
          if (showYdsDown)
            Text(
              'yds',
              style: AppTextStyle.roboto(),
            ),
          if (showTargetTolerance)
            Text(
              toleranceValue,
              style: AppTextStyle.roboto(
                color: AppColors.secondaryText,
              ),
            ),
        ],
      ),
    );
  }
}
