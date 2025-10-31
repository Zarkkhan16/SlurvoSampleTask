import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';

class MetricDisplay extends StatelessWidget {
  final String value;
  final String label;
  final String unit;

  const MetricDisplay({
    super.key,
    required this.value,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.oswald(
            fontSize: 70,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          "$label\n$unit",
          textAlign: TextAlign.center,
          style: AppTextStyle.roboto(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
