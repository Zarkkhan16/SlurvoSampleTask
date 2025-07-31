import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_task/core/constants/app_colors.dart';
import 'package:sample_task/core/constants/app_strings.dart';

class SessionViewButton extends StatelessWidget {
  const SessionViewButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: AppColors.buttonText,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        ),
        child: Text(
          AppStrings.sessionViewText,
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
      ),
    );
  }
}
