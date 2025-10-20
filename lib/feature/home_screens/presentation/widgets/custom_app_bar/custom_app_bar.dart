import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_images.dart';
import '../../../../golf_device/domain/entities/device_entity.dart';
import '../../../../setting/persentation/pages/setting_screen.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final DeviceEntity? connectedDevice;
//   final   List<DiscoveredService>? services ;
//   final   bool selectedUnit ;
//   final bool showSettingButton;
//   const CustomAppBar({super.key, this.connectedDevice, this.showSettingButton = false, this.services,this.selectedUnit=false});
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: AppColors.primaryBackground,
//       elevation: 0,
//       title: SizedBox(
//         height: 180,
//         child: Image.asset(
//           AppImages.splashLogo,
//         ),
//       ),
//       centerTitle: true,
//       leading: const Padding(
//         padding: EdgeInsets.only(left: 16.0),
//         child:
//             Icon(Icons.account_circle, color: AppColors.primaryText, size: 30),
//       ),
//       actions:  [
//
//         ValueListenableBuilder<int>(
//           valueListenable: batteryNotifier,
//           builder: (context, value, _) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Icon(
//                 getBatteryIcon(value),  // icon dynamic
//                 color: getBatteryColor(value), // color dynamic
//                 size: 30,
//               ),
//             );
//           },
//         ),
//
//         if(showSettingButton)
//         GestureDetector(
//           onTap: (){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => SettingScreen(connectedDevice: connectedDevice,services: services??[],selectedUnit: selectedUnit,),
//               ),
//             );
//           },
//           child: Padding(
//             padding: EdgeInsets.only(right: 16.0),
//             child: Icon(Icons.settings, color: AppColors.primaryText, size: 30),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
//
// /// globally accessible
// final ValueNotifier<int> batteryNotifier = ValueNotifier(0);
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSettingButton;
  final bool showBatteryLevel;
  final int batteryLevel;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onProfilePressed;
  final IconData rightTopIcon;

  const CustomAppBar({
    super.key,
    this.showSettingButton = false,
    this.showBatteryLevel = false,
    this.batteryLevel = 0,
    this.onSettingsPressed,
    this.onProfilePressed,
    this.rightTopIcon = Icons.settings,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      title: SizedBox(
        height: 180,
        child: Image.asset(AppImages.splashLogo),
      ),
      centerTitle: true,
      leading: GestureDetector(
        onTap: onProfilePressed,
        child: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(
            Icons.account_circle,
            color: AppColors.primaryText,
            size: 30,
          ),
        ),
      ),
      actions: [
        if(showBatteryLevel)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              getBatteryIcon(batteryLevel),
              color: getBatteryColor(batteryLevel),
              size: 30,
            ),
          ),

        if (showSettingButton)
          GestureDetector(
            onTap: onSettingsPressed,
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                rightTopIcon,
                color: AppColors.primaryText,
                size: 30,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


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
      return Colors.grey;
    case 1:
      return Colors.redAccent;
    case 2:
      return Colors.orangeAccent;
    case 3:
      return Colors.greenAccent;
    default:
      return Colors.white;
  }
}