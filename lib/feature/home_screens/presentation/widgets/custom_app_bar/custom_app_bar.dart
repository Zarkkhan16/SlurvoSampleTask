import 'package:flutter/material.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:Slurvo/core/constants/app_images.dart'; // Make sure this contains `slurvoLogo`

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
          AppImages.slurvoLogo,
        ),
      ),
      centerTitle: true,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16.0),
        child:
            Icon(Icons.account_circle, color: AppColors.primaryText, size: 30),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.settings, color: AppColors.primaryText, size: 30),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
