import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';

class SessionViewButton extends StatelessWidget {
  final VoidCallback? onSessionClick;
  final String buttonText;
  final Color? backgroundColor, textColor;
  final String? iconSvg;

  // 🔹 OPTIONAL LOADING FLAG
  final bool isLoading;

  const SessionViewButton({
    super.key,
    required this.onSessionClick,
    this.buttonText = AppStrings.sessionViewText,
    this.backgroundColor = AppColors.buttonBackground,
    this.textColor = AppColors.buttonText,
    this.iconSvg,
    this.isLoading = false, // default → no loader
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
        onPressed: isLoading ? null : onSessionClick, // disable while loading
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

        // 🔹 ONLY CONTENT CHANGES — SIZE STAYS SAME
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Row(
            children: [
              if (iconSvg != null) ...[
                SvgPicture.asset(iconSvg!),
                const SizedBox(width: 15),
              ],
              Text(
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
            ],
          ),
        ),
      ),
    );
  }
}

