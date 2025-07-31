import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_task/core/constants/app_colors.dart';
import 'package:sample_task/core/constants/app_strings.dart';

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.primaryText, size: 30),
        Text(
          AppStrings.shotAnalysisTitle,
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ),

        const SizedBox(),
      ],
    );
  }
}
