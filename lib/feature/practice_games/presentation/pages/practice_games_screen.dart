import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_bloc.dart';
import 'package:onegolf/feature/practice_games/presentation/pages/longest_drive_main_page.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/gaming_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_app_bar.dart';
import '../widgets/top_button.dart';

class PracticeGamesScreen extends StatelessWidget {
  const PracticeGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        child: Column(
          children: [
            HeaderRow(
              headingName: "Practice Games",
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  TopButton(
                    label: "LeadersBoards",
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  TopButton(
                    label: "Help",
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  GamingCard(
                    svgPath: AppImages.combineTestIcon,
                    title: "Combine Test",
                    subtitle: "Assess overall skill level",
                    onTap: () {},
                  ),
                  SizedBox(height: 16),
                  GamingCard(
                    svgPath: AppImages.ladderDrillIcon,
                    title: "Distance Control Drills",
                    subtitle: "Focused accuracy with increasing difficulty",
                    onTap: () {},
                  ),
                  SizedBox(height: 16),
                  GamingCard(
                    svgPath: AppImages.clubGappingIcon,
                    title: "Club Gapping",
                    subtitle: "Hone distance control with different clubs",
                    onTap: () {},
                  ),
                  SizedBox(height: 16),
                  GamingCard(
                    svgPath: AppImages.longestDriveIcon,
                    title: "Longest Drive",
                    subtitle: "Power meets precision",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<PracticeGamesBloc>(),
                            child: const LongestDriveMainPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
