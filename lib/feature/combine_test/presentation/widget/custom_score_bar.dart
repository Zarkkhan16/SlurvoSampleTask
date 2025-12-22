import 'package:flutter/material.dart';

class CustomScoreBar extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double height;
  final Color fillColor;
  final Color bgColor;
  final TextStyle? textStyle;

  const CustomScoreBar({
    super.key,
    required this.value,
    this.min = 0.0,
    required this.max,
    this.height = 24,
    this.fillColor = const Color(0xFF999999),
    this.bgColor = const Color(0xFF222222),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final double safeValue = value.clamp(min, max);
    final double percent = ((safeValue - min) / (max - min)).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        final double pillWidth = height * 2;
        final double fillWidth = barWidth * percent;

        return Stack(
          children: [
            // Background bar
            Container(
              width: barWidth,
              height: height,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Only show fill if value > min
            if (percent > 0)
              Container(
                width: fillWidth,
                height: height,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            // The pill with score (always visible)
            Positioned(
              left: percent == 0 ? 0 : (fillWidth - pillWidth).clamp(0.0, barWidth - pillWidth),
              top: 0,
              child: Container(
                width: pillWidth,
                height: height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
                child: Text(
                  safeValue.toStringAsFixed(1),
                  style: textStyle ??
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.0,
                      ),
                  textAlign: TextAlign.center,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

