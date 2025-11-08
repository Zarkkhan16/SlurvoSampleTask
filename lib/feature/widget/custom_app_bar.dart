// import 'package:flutter/material.dart';
// import 'package:onegolf/core/constants/app_colors.dart';
// import 'package:onegolf/core/constants/app_images.dart';
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final bool showSettingButton;
//   final bool showBatteryLevel;
//   final int batteryLevel;
//   final VoidCallback? onSettingsPressed;
//   final VoidCallback? onProfilePressed;
//   final IconData rightTopIcon;
//
//   const CustomAppBar({
//     super.key,
//     this.showSettingButton = false,
//     this.showBatteryLevel = false,
//     this.batteryLevel = 0,
//     this.onSettingsPressed,
//     this.onProfilePressed,
//     this.rightTopIcon = Icons.settings,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: AppColors.primaryBackground,
//       elevation: 0,
//       title: SizedBox(
//         height: 180,
//         child: Image.asset(AppImages.splashLogo),
//       ),
//       centerTitle: true,
//       leading: GestureDetector(
//         onTap: onProfilePressed,
//         child: const Padding(
//           padding: EdgeInsets.only(left: 16.0),
//           child: Icon(
//             Icons.account_circle,
//             color: AppColors.primaryText,
//             size: 30,
//           ),
//         ),
//       ),
//       actions: [
//         if(showBatteryLevel)
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: Icon(
//               getBatteryIcon(batteryLevel),
//               color: getBatteryColor(batteryLevel),
//               size: 30,
//             ),
//           ),
//
//         if (showSettingButton)
//           GestureDetector(
//             onTap: onSettingsPressed,
//             child: Padding(
//               padding: EdgeInsets.only(right: 16.0),
//               child: Icon(
//                 rightTopIcon,
//                 color: AppColors.primaryText,
//                 size: 30,
//               ),
//             ),
//           ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Divider(thickness: 1, color: AppColors.dividerColor),
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
//
//
// IconData getBatteryIcon(int battery) {
//   switch (battery) {
//     case 0:
//       return Icons.battery_0_bar;
//     case 1:
//       return Icons.battery_2_bar;
//     case 2:
//       return Icons.battery_4_bar;
//     case 3:
//       return Icons.battery_full;
//     default:
//       return Icons.battery_unknown;
//   }
// }
//
// Color getBatteryColor(int battery) {
//   switch (battery) {
//     case 0:
//       return Colors.grey;
//     case 1:
//       return Colors.redAccent;
//     case 2:
//       return Colors.orangeAccent;
//     case 3:
//       return Colors.greenAccent;
//     default:
//       return Colors.white;
//   }
// }
import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_images.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.07; // 7% of width
    final logoHeight = screenWidth * 0.15;
    final verticalPadding = screenWidth * 0.001;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        // bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onProfilePressed,
                    child: Icon(
                      Icons.account_circle,
                      color: AppColors.primaryText,
                      size: iconSize,
                    ),
                  ),

                  // Center logo wrapped with Flexible to prevent overflow
                  Flexible(
                    child: Image.asset(
                      AppImages.splashLogo,
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Right icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showBatteryLevel)
                        Padding(
                          padding: EdgeInsets.only(right: showSettingButton ? 8.0 : 0),
                          child: Icon(
                            getBatteryIcon(batteryLevel),
                            color: getBatteryColor(batteryLevel),
                            size: iconSize,
                          ),
                        ),
                      if (showSettingButton)
                        GestureDetector(
                          onTap: onSettingsPressed,
                          child: Icon(
                            rightTopIcon,
                            color: AppColors.primaryText,
                            size: iconSize,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: AppColors.dividerColor,
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final screenWidth = WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;
    final height = screenWidth * 0.25;
    return Size.fromHeight(height);
  }
}

// Battery helper functions
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
