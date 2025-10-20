import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  static TextStyle roboto({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontStyle: fontStyle,
        height: height,
        decoration: decoration,
      ),
    );
  }

  static TextStyle oswald({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.oswald(
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontStyle: fontStyle,
        height: height,
        decoration: decoration,
      ),
    );
  }
  static TextStyle titleBold({
    double fontSize = 22,
    Color color = Colors.white,
  }) {
    return roboto(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    Color color = Colors.white70,
  }) {
    return roboto(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}
