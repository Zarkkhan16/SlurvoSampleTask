import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/gradient_border_container.dart';

class PlayerChip extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PlayerChip({
    super.key,
    required this.name,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: GradientBorderContainer(
        borderRadius: 15,
        child: Text(
          name,
          style:
          AppTextStyle.roboto(fontSize: 12, color: AppColors.secondaryText),
        ),
      )
    );
  }
}