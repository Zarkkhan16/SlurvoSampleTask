import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';

class StatRowWidget extends StatelessWidget {
  final String label1;
  final String value1;
  final String label2;
  final String value2;

  const StatRowWidget({
    Key? key,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SingleStat(label: label1, value: value1),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SingleStat(label: label2, value: value2),
        ),
      ],
    );
  }
}

class _SingleStat extends StatelessWidget {
  final String label;
  final String value;

  const _SingleStat({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 20,
      containerHeight: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyle.roboto(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: AppTextStyle.oswald(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
