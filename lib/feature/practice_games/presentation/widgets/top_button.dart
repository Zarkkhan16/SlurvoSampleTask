import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';

class TopButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const TopButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade800,
          ),
        ),
        child: Text(
            label,
            style: AppTextStyle.roboto(
              fontSize: 16,
            )
        ),
      ),
    );
  }
}