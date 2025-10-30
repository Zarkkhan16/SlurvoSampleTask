import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';

class SessionViewButton extends StatelessWidget {
  final VoidCallback? onSessionClick;
  final String buttonText;
  final Color? backgroundColor, textColor;

  const SessionViewButton({
    super.key,
    required this.onSessionClick,
    this.buttonText = AppStrings.sessionViewText,
    this.backgroundColor = AppColors.buttonBackground,
    this.textColor = AppColors.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final buttonHeight = screenHeight * 0.07;
    final fontSize = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.018;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onSessionClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
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
            buttonText,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: textColor,
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
