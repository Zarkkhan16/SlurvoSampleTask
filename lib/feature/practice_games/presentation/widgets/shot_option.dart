import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/gradient_border_container.dart';

class ShotOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const ShotOption({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GradientBorderContainer(
        borderRadius: 12,
        backgroundColor:
        isSelected ? AppColors.buttonBackground : AppColors.cardBackground,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Text(text,
            style: AppTextStyle.roboto(
              color:
              isSelected ? AppColors.buttonText : AppColors.secondaryText,
            )),
      ),
    );
  }
}