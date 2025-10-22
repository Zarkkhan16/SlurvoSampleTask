import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
class ShotComparisonButton extends StatelessWidget {
  const ShotComparisonButton({super.key, this.onTap, required this.headingText, this.icon = Icons.bar_chart_rounded});
  final VoidCallback? onTap;
  final String headingText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(128, 128, 128, 1.0),
              Color.fromRGBO(128, 128, 128, 0.05),
              Color.fromRGBO(128, 128, 128, 0.3),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(1), // perfect 1px margin
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(31), // slightly smaller for perfect fit
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                headingText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
