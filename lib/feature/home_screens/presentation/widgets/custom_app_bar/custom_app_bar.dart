import 'package:OneGolf/core/di/injection_container.dart' as di;
import 'package:OneGolf/core/utils/navigation_helper.dart';
import 'package:OneGolf/feature/ble/presentation/block/ble_bloc.dart';
import 'package:OneGolf/feature/ble/presentation/block/ble_event.dart';
import 'package:OneGolf/feature/scanned_devices_screen/scanned_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:OneGolf/core/constants/app_colors.dart';
import 'package:OneGolf/core/constants/app_images.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/ble_command_helper.dart';
import '../../../../setting/setting_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BleHelper? bleHelper;
  const CustomAppBar({super.key, this.bleHelper});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      title: SizedBox(
        height: 180,
        child: Image.asset(
          AppImages.splashLogo,
        ),
      ),
      centerTitle: true,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child:
            Icon(Icons.account_circle, color: AppColors.primaryText, size: 30),
      ),
      actions:  [

        ValueListenableBuilder<int>(
          valueListenable: batteryNotifier,
          builder: (context, value, _) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                getBatteryIcon(value),  // icon dynamic
                color: getBatteryColor(value), // color dynamic
                size: 30,
              ),
            );
          },
        ),

        GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingScreen(bleHelper: bleHelper ?? BleHelper()),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: AppColors.primaryText, size: 30),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// globally accessible
final ValueNotifier<int> batteryNotifier = ValueNotifier(0);


IconData getBatteryIcon(int battery) {
  switch (battery) {
    case 0:
      return Icons.battery_0_bar;
    case 1:
      return Icons.battery_2_bar;
    case 2:
      return Icons.battery_4_bar;
    case 3:
      return Icons.battery_full;
    default:
      return Icons.battery_unknown;
  }
}

Color getBatteryColor(int battery) {
  switch (battery) {
    case 0:
      return Colors.grey; // blank
    case 1:
      return Colors.redAccent; // low
    case 2:
      return Colors.orangeAccent; // middle
    case 3:
      return Colors.greenAccent; // full
    default:
      return Colors.white;
  }
}