import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/gradient_border_container.dart';

class PlayerChip extends StatelessWidget {
  final String name;

  const PlayerChip({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 15,
      child: Text(
        name,
        style:
        AppTextStyle.roboto(fontSize: 12, color: AppColors.secondaryText),
      ),
    );
  }
}