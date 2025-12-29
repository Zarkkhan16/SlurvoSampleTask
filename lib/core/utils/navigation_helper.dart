import 'package:flutter/material.dart';
import 'package:onegolf/core/services/ble_connection_helper.dart';
import 'package:onegolf/feature/auth/presentation/pages/sign_in_screen.dart';
import 'package:onegolf/feature/bottom_controller.dart';

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

  static Future<void> navigateTabWithBleCheck({
    required BuildContext context,
    required int tabIndex,
  }) async {
    final isConnected = await BleConnectionHelper.ensureDeviceConnected(context);

    if (isConnected && context.mounted) {
      BottomNavController.goToTab(tabIndex);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Device connection required',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }


  static Future<void> navigateWithBleCheck({
    required BuildContext context,
    required Widget destination,
    required String screenName,
  }) async {
    final isConnected = await BleConnectionHelper.ensureDeviceConnected(context);

    if (!context.mounted) return;

    if (isConnected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: screenName),
          builder: (_) => destination,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Device connection required',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  static Future<bool> isDeviceConnected(BuildContext context) async {
    final isConnected = await BleConnectionHelper.ensureDeviceConnected(context);

    if (!context.mounted) return false;

    return isConnected;
  }

}
