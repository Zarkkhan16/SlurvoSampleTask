import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Slurvo/core/constants/app_images.dart';
import 'package:Slurvo/core/constants/app_strings.dart';
import 'package:Slurvo/core/utils/navigation_helper.dart';

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
        child: Image.asset(
          AppImages.splashLogo,
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
