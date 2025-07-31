import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Slurvo/core/constants/app_images.dart';
import 'package:Slurvo/core/constants/app_strings.dart';
import 'package:Slurvo/core/utils/navigation_helper.dart'; // 👈 import the helper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    NavigationHelper.initializeAndNavigateSplash(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.slurvoLogo,
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.turnOnBluetooth,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
