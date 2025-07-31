import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_task/core/constants/app_colors.dart';

class ActionButton extends StatelessWidget {
  final String? svgAssetPath;
  final String text;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    this.svgAssetPath,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.buttonBackground,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAssetPath != null) ...[
              SvgPicture.asset(svgAssetPath!, height: 20, width: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}