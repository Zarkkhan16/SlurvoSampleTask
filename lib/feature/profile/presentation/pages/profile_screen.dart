import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:onegolf/feature/auth/presentation/bloc/auth_event.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            HeaderRow(headingName: "Your Profile"),
            SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                AppImages.userDummyImage,
              ),
              backgroundColor: Colors.grey[700],
            ),
            SizedBox(height: 10),
            Text(
              AppStrings.userProfileData.name,
              style: AppTextStyle.roboto(),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.cardBackground,
              ),
              child: Text(
                'Free',
                style: AppTextStyle.roboto(),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Joined ${formatJoinDate(AppStrings.userProfileData.createdAt)} - Last Login ${formatLastLoginDate(DateTime.now())}',
              style: AppTextStyle.roboto(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature is under development.'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: GradientBorderContainer(
                borderRadius: 20,
                containerHeight: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Profile",
                      style: AppTextStyle.roboto(),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature is under development.'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: GradientBorderContainer(
                borderRadius: 20,
                containerHeight: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Change Password",
                      style: AppTextStyle.roboto(),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
              child: GradientBorderContainer(
                backgroundColor: AppColors.red,
                borderWidth: 0,
                borderRadius: 20,
                containerHeight: 60,
                containerWidth: double.infinity,
                child: Center(
                  child: Text(
                    "LogOut",
                    style: AppTextStyle.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String formatJoinDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM yyyy').format(date);
  }

  String formatLastLoginDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
