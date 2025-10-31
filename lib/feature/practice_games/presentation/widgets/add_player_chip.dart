import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/gradient_border_container.dart';

class AddPlayerChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddPlayerChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GradientBorderContainer(
        borderRadius: 15,
        child: Text(
          label,
          style:
          AppTextStyle.roboto(fontSize: 12, color: AppColors.secondaryText),
        ),
      ),
    );
  }
}