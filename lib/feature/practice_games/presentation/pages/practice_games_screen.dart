import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/utils/navigation_helper.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/club_gapping/presentation/bloc/club_gapping_bloc.dart';
import 'package:onegolf/feature/club_gapping/presentation/pages/club_selection_page.dart';
import 'package:onegolf/feature/combine_test/presentation/pages/combine_test_page.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_bloc.dart';
import 'package:onegolf/feature/practice_games/presentation/pages/longest_drive_main_page.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/gaming_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/di/injection_container.dart';
import '../../../club_gapping/presentation/bloc/club_gapping_event.dart';
import '../../../distance_control_drills/presentation/pages/distance_control_drills_screen.dart';
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
      // bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        child: Column(
          children: [
            HeaderRow(
              headingName: "Practice Games",
              backButtonHide: true,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: "CombineTestPage"),
                          builder: (context) => CombineTestPage(),
                        ),
                      );
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('Combine test game coming soon!'),
                      //     backgroundColor: Colors.white,
                      //     duration: Duration(seconds: 1),
                      //   ),
                      // );
                    },
                  ),
                  SizedBox(height: 16),
                  GamingCard(
                    svgPath: AppImages.ladderDrillIcon,
                    title: "Distance Control Drills",
                    subtitle: "Focused accuracy with increasing difficulty",
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DistanceControlDrillsScreen(),
                      //   ),
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: "DistanceControlDrillsScreen"),
                          builder: (_) => DistanceControlDrillsScreen(),
                        ),
                      );

                    },
                  ),
                  SizedBox(height: 16),
                  GamingCard(
                    svgPath: AppImages.clubGappingIcon,
                    title: "Club Gapping",
                    subtitle: "Hone distance control with different clubs",
                    onTap: () async {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => BlocProvider.value(
                      //       value: context.read<ClubGappingBloc>(),
                      //       child: const ClubSelectionScreen(),
                      //     ),
                      //   ),
                      // );
                      final bleRepo = sl<BleManagementRepository>();

                      if (bleRepo.isConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: "ClubSelectionScreen"),
                            builder: (_) => BlocProvider.value(
                              value: context.read<ClubGappingBloc>(),
                              child: const ClubSelectionScreen(),
                            ),
                          ),
                        );
                      } else {
                        final isConnected = await NavigationHelper.isDeviceConnected(context);
                        if (!isConnected) return;
                        if(isConnected){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: "ClubSelectionScreen"),
                              builder: (_) => BlocProvider.value(
                                value: context.read<ClubGappingBloc>(),
                                child: const ClubSelectionScreen(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  GamingCard(
                    svgPath: AppImages.longestDriveIcon,
                    title: "Longest Drive",
                    subtitle: "Power meets precision",
                    onTap: () async {

                      final bleRepo = sl<BleManagementRepository>();

                      if (bleRepo.isConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<PracticeGamesBloc>(),
                              child: const LongestDriveMainPage(),
                            ),
                          ),
                        );
                      } else {
                        final isConnected = await NavigationHelper.isDeviceConnected(context);
                        if (!isConnected) return;
                        if(isConnected){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<PracticeGamesBloc>(),
                                child: const LongestDriveMainPage(),
                              ),
                            ),
                          );
                        }
                      }
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
