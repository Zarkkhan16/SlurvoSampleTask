import 'package:flutter/material.dart';
import 'package:onegolf/feature/auth/presentation/pages/sign_in_screen.dart';

class NavigationHelper {
  static void initializeAndNavigateSplash(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     // builder: (_) => GolfDeviceScreen(),
        //     // builder: (_) => SignInScreen(),
        //   ),
        // );
      });
    });
  }
}
