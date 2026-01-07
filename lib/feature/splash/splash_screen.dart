// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:onegolf/core/constants/app_images.dart';
// import 'package:onegolf/core/constants/app_strings.dart';
// import 'package:onegolf/core/utils/navigation_helper.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     NavigationHelper.initializeAndNavigateSplash(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Image.asset(
//           AppImages.splashLogo,
//           width: 300,
//           height: 300,
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
//
// import '../../core/constants/app_images.dart';
// import '../golf_device/presentation/pages/golf_device_screen.dart';
// import '../landing_dashboard/persentation/pages/landing_dashboard.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToHome();
//   }
//
//   void _navigateToHome() {
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         '/SignInScreen',
//             (route) => false,
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Image.asset(
//           AppImages.splashLogo,
//           width: 300,
//           height: 300,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_images.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_event.dart';
import '../auth/presentation/bloc/auth_state.dart';
import '../bottom_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          BottomNavController.currentIndex.value = 0;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/MainScreen',
                (route) => false,
          );
        }
        else if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/SignInScreen',
                (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image.asset(
            AppImages.splashLogo,
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}