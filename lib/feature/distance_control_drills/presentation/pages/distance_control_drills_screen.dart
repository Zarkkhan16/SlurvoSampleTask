import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/pages/distance_master_setup_screen.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/gaming_card.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';

import '../../../../core/di/injection_container.dart' as di;

class DistanceControlDrillsScreen extends StatelessWidget {
  const DistanceControlDrillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
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
                    padding: EdgeInsets.symmetric(horizontal: 10,  vertical: 16),
                    title: "Target Zone",
                    subtitle:
                        'Hone in one Carry distance, Pure repetition, Pure mastery.',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Target Zone game coming soon!'),
                          backgroundColor: Colors.white,
                        ),
                      );
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => di.sl<DistanceMasterBloc>(),
                            child: DistanceMasterSetupScreen(),
                          ),
                        ),
                      );
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
                    onTap: () {
                      // TODO: Navigate to Ladder Drill game
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ladder Drill game coming soon!'),
                          backgroundColor: Colors.white,
                        ),
                      );
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
