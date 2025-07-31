import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Slurvo/core/constants/app_strings.dart';

class GlassmorphismCard extends StatelessWidget {
  final String value;
  final String name;
  final String unit;

  const GlassmorphismCard({
    super.key,
    this.value = '0.00',
    this.name = AppStrings.clubSpeedMetric,
    this.unit =AppStrings.mphUnit
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff2525258c),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned.fill(
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
            ),
          ),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    unit,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white60,
                        height: 1.125, // 18px / 16px = 1.125
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}