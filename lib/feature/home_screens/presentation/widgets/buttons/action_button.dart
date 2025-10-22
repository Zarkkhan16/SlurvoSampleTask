// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:onegolf/core/constants/app_colors.dart';
//
// class ActionButton extends StatelessWidget {
//   final String? svgAssetPath;
//   final String text;
//   final VoidCallback onPressed;
//   final Color? buttonBackgroundColor,textColor;
//
//   const ActionButton({
//     super.key,
//     this.svgAssetPath,
//     required this.text,
//     required this.onPressed,
//     this.buttonBackgroundColor = AppColors.buttonBackground,
//     this.textColor = AppColors.buttonText
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final buttonHeight = size.height * 0.07; // ~7% of screen height
//     final fontSize = size.width * 0.045; // scales with screen width
//     final iconSize = size.width * 0.05; // responsive icon size
//
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         height: buttonHeight.clamp(45.0, 65.0), // keep within range
//         padding: EdgeInsets.symmetric(
//           horizontal: size.width * 0.05,
//           vertical: size.height * 0.012,
//         ),
//         decoration: BoxDecoration(
//           color: buttonBackgroundColor,
//           borderRadius: BorderRadius.circular(25),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (svgAssetPath != null) ...[
//               SvgPicture.asset(
//                 svgAssetPath!,
//                 height: iconSize.clamp(16.0, 24.0),
//                 width: iconSize.clamp(16.0, 24.0),
//               ),
//               SizedBox(width: size.width * 0.02),
//             ],
//             Flexible(
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   text,
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.roboto(
//                     textStyle: TextStyle(
//                       color: textColor,
//                       fontSize: fontSize.clamp(16.0, 22.0),
//                       fontWeight: FontWeight.w700,
//                       height: 1.0,
//                       letterSpacing: 0.0,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:flutter/services.dart';

class ActionButton extends StatelessWidget {
  final String? svgAssetPath;
  final String text;
  final VoidCallback onPressed;
  final Color? buttonBackgroundColor, textColor;

  const ActionButton({
    super.key,
    this.svgAssetPath,
    required this.text,
    required this.onPressed,
    this.buttonBackgroundColor = AppColors.buttonBackground,
    this.textColor = AppColors.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.07;
    final fontSize = size.width * 0.045;
    final iconSize = size.width * 0.05;

    return GestureDetector(
      onTap:  () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        height: buttonHeight.clamp(45.0, 65.0),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.012,
        ),
        decoration: BoxDecoration(
          color: buttonBackgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAssetPath != null) ...[
              SvgPicture.asset(
                svgAssetPath!,
                height: iconSize.clamp(16.0, 24.0),
                width: iconSize.clamp(16.0, 24.0),
              ),
              SizedBox(width: size.width * 0.02),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    color: textColor,
                    fontSize: fontSize.clamp(14.0, 20.0),
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}