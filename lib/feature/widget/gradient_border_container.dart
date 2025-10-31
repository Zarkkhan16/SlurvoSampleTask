import 'package:flutter/material.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  const GradientBorderContainer({
    Key? key,
    required this.child,
    this.borderRadius = 32,
    this.borderWidth = 1,
    this.gradientColors = const [
      Color.fromRGBO(128, 128, 128, 1.0),
      Color.fromRGBO(128, 128, 128, 0.05),
      Color.fromRGBO(128, 128, 128, 0.3),
    ],
    this.backgroundColor = const Color(0xFF2A2A2A),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.margin,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: gradientColors,
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}
