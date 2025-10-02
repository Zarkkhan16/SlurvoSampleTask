import 'package:onegolf/core/di/injection_container.dart' as di;
import 'package:onegolf/core/utils/navigation_helper.dart';
import 'package:onegolf/feature/ble/presentation/block/ble_bloc.dart';
import 'package:onegolf/feature/ble/presentation/block/ble_event.dart';
import 'package:onegolf/feature/scanned_devices_screen/scanned_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

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
        GestureDetector(
          onTap: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => di.sl<BleBloc>()..add(StartScanEvent()),
                  child: const ScannedDevicesScreen(),
                ),
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
