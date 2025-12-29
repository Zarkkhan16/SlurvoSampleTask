import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:onegolf/core/di/injection_container.dart';
import 'package:onegolf/core/utils/navigation_helper.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/pages/distance_master_setup_screen.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/pages/ladder_drill_setup_screen.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/pages/target_zone_setup_screen.dart';
import 'package:onegolf/feature/practice_games/presentation/pages/practice_games_screen.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/gaming_card.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import '../../../../core/di/injection_container.dart' as di;

class DistanceControlDrillsScreen extends StatelessWidget {
  const DistanceControlDrillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(),
      // bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        child: Column(
          children: [
            HeaderRow(
              headingName: "Distance Control Drill",
            ),
            SizedBox(height: 20),
            // Game Options
            Expanded(
              child: Column(
                children: [
                  // Target Zone Game
                  GamingCard(
                    svgPath: AppImages.combineTestIcon,
                    svgHeight: 30,
                    svgWidth: 30,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                    title: "Target Zone",
                    subtitle:
                        'Hone in one Carry distance, Pure repetition, Pure mastery.',
                    onTap: () async {

                      final bleRepo = sl<BleManagementRepository>();

                      if (bleRepo.isConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<TargetZoneBloc>(),
                              child: TargetZoneSetupScreen(),
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
                                value: context.read<TargetZoneBloc>(),
                                child: TargetZoneSetupScreen(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 15),
                  GamingCard(
                    svgPath: AppImages.distanceMasterIcon,
                    svgHeight: 30,
                    svgWidth: 30,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                    title: "Distance Master",
                    subtitle:
                        'Hit 3 perfect shots in a row to level up. Window Shrinks. Challenge grows.',
                    onTap: () async {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => BlocProvider.value(
                      //       value: context.read<DistanceMasterBloc>(),
                      //       child: DistanceMasterSetupScreen(),
                      //     ),
                      //   ),
                      // );


                      final bleRepo = sl<BleManagementRepository>();

                      if (bleRepo.isConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings:
                            RouteSettings(name: "DistanceMasterSetupScreen"),
                            builder: (_) => BlocProvider.value(
                              value: context.read<DistanceMasterBloc>(),
                              child: DistanceMasterSetupScreen(),
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
                              settings:
                              RouteSettings(name: "DistanceMasterSetupScreen"),
                              builder: (_) => BlocProvider.value(
                                value: context.read<DistanceMasterBloc>(),
                                child: DistanceMasterSetupScreen(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 15),
                  GamingCard(
                    svgPath: AppImages.ladderDrillIcon,
                    svgHeight: 30,
                    svgWidth: 30,
                    iconBtwTextWidth: 23,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                    title: "Ladder Drills",
                    subtitle:
                        'Hone in one Carry distance, Pure repetition, Pure mastery.',
                    onTap: () async {

                      final bleRepo = sl<BleManagementRepository>();

                      if (bleRepo.isConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: di.sl<LadderDrillBloc>(),
                              child: LadderDrillSetupScreen(),
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
                                value: di.sl<LadderDrillBloc>(),
                                child: LadderDrillSetupScreen(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  Spacer(),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(AppImages.distanceMasterImage),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
