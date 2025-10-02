import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:OneGolf/core/constants/app_colors.dart';
import 'package:OneGolf/core/constants/app_strings.dart';

class SessionViewButton extends StatelessWidget {
  const SessionViewButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final buttonHeight = screenHeight * 0.07; // ~7% of screen height
    final fontSize = screenWidth * 0.05; // ~5% of screen width
    final verticalPadding = screenHeight * 0.018; // ~1.8% of screen height

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: AppColors.buttonText,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding.clamp(12.0, 20.0),
          ),
          minimumSize: Size(double.infinity, buttonHeight.clamp(48.0, 70.0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppStrings.sessionViewText,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: AppColors.buttonText,
                fontSize: fontSize.clamp(16.0, 24.0),
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
