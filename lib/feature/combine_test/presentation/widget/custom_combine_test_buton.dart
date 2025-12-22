import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';

class CustomCombineTestButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const CustomCombineTestButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GradientBorderContainer(
        borderRadius: 32,
        containerWidth: double.infinity,
        containerHeight: 70,
        child: Center(
          child: Text(
            text,
            style: AppTextStyle.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
