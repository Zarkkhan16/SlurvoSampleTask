import 'package:flutter/material.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:Slurvo/core/constants/app_images.dart';
import 'package:Slurvo/core/constants/app_strings.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/buttons/action_button.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/buttons/session_view_button.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/custom_bar/custom_bar.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/grid/shot_grid_view.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/header/header_row.dart';

import '../../../../choose_club_screen/presentation/choose_club_screen_page.dart';

class ShotAnalysisBody extends StatefulWidget {
  const ShotAnalysisBody({super.key});

  @override
  State<ShotAnalysisBody> createState() => _ShotAnalysisBodyState();
}

class _ShotAnalysisBodyState extends State<ShotAnalysisBody> {
  Club? mySelectedClub;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(thickness: 1, color: AppColors.dividerColor),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 60,
                  child: HeaderRow(
                    showClubName: true,
                    headingName: "Shot Analysis",
                    selectedClub: mySelectedClub,
                    onClubSelected: (club) {
                      setState(() {
                        mySelectedClub = club;
                      });
                    },
                  ),
                ),
                SizedBox(height: 14),
                CustomizeBar(),
                SizedBox(height: 15),
                Expanded(child: ShotGridView()),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ActionButton(
                        text: AppStrings.deleteShotText,
                        onPressed: () {},
                      ),
                      ActionButton(
                        svgAssetPath: AppImages.groupIcon,
                        text: AppStrings.dispersionText,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 17),
                SessionViewButton(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
