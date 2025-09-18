import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:Slurvo/core/constants/app_strings.dart';

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = screenWidth * 0.07; // ~7% of screen width
    final fontSize = screenWidth * 0.07; // ~7% of screen width

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.arrow_back_ios_new_outlined,
          color: AppColors.primaryText,
          size: iconSize.clamp(20.0, 34.0),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppStrings.shotAnalysisTitle,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: fontSize.clamp(18.0, 32.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(), // placeholder to balance Row
      ],
    );
  }
}
