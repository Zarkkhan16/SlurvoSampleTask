import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_event.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_state.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';
import '../../../presentation/pages/distance_control_drills_screen.dart';
import 'distance_master_setup_screen.dart';

class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: BlocBuilder<DistanceMasterBloc, DistanceMasterState>(
        builder: (context, state) {
          if (state is SessionCompleteState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderRow(headingName: "Session Complete"),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      "Great Work! Here's how you did ",
                      style: AppTextStyle.roboto(),
                    ),
                  ),
                  SizedBox(height: 20),
                  _customRow(
                    "Highest Level Reached",
                    "Level ${state.highestLevelReached}",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _customRow(
                    "Final Target Distance",
                    "${state.highestLevelReached} yds",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _customRow(
                    "Total Successful Hits",
                    "${state.totalSuccessfulHits}",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _customRow(
                    "Longest Streak",
                    state.longestStreak,
                  ),
                  SizedBox(height: 5),
                  Spacer(),
                  GradientBorderContainer(
                    borderRadius: 16,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    containerWidth: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level Breakdown',
                          style: AppTextStyle.roboto(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Table(
                          columnWidths: {
                            0: FixedColumnWidth(60),
                            1: FixedColumnWidth(75),
                            2: FixedColumnWidth(75),
                            3: FixedColumnWidth(75),
                            4: FixedColumnWidth(75),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.dividerColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              children: [
                                _tableHeading('Level', textAlign: TextAlign.center),
                                _tableHeading('Target', textAlign: TextAlign.center),
                                _tableHeading('Window', textAlign: TextAlign.center),
                                _tableHeading('Attempts', textAlign: TextAlign.center),
                                _tableHeading('Success', textAlign: TextAlign.center),
                              ],
                            ),
                            ...state.allLevels.map(
                              (level) => TableRow(
                                children: [
                                  _tableValue('${level.level}', textAlign: TextAlign.center),
                                  _tableValue('${level.targetDistance} yds', textAlign: TextAlign.center),
                                  _tableValue('${level.minDistance}-${level.maxDistance} yd', textAlign: TextAlign.center),
                                  _tableValue('${level.shots.length}', textAlign: TextAlign.center),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: Icon(
                                        level.completed
                                            ? Icons.check
                                            : Icons.cancel,
                                        color: level.completed
                                            ? Colors.green
                                            : Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  GradientBorderContainer(
                    borderRadius: 16,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coaching Tip',
                          style: AppTextStyle.roboto(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _getCoachingTip(state),
                          style: AppTextStyle.oswald(),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  SessionViewButton(
                    onSessionClick: () {
                      context
                          .read<DistanceMasterBloc>()
                          .add(RestartGameEvent());
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DistanceControlDrillsScreen(),
                        ),
                      );
                    },
                    buttonText: "Restart",
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _customRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyle.roboto(fontSize: 16),
          ),
          Text(
            value,
            style: AppTextStyle.oswald(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _tableHeading(String title, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text(
        title,
        style: AppTextStyle.roboto(),
        textAlign: textAlign,
      ),
    );
  }

  Widget _tableValue(String value, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        value,
        style: AppTextStyle.oswald(),
        textAlign: textAlign,
      ),
    );
  }

  String _getCoachingTip(SessionCompleteState state) {
    double successRate =
        (state.totalSuccessfulHits / state.totalAttempts) * 100;

    if (successRate >= 75) {
      return 'Excellent consistency! You were most consistent between ${state.allLevels.first.targetDistance}-${state.allLevels.last.targetDistance} yds - build confidence here before moving up.';
    } else if (successRate >= 50) {
      return 'Good progress! Focus on maintaining tempo and balance throughout your swing to improve consistency.';
    } else {
      return 'Keep practicing! Try reducing your target window or working on shorter distances to build consistency first.';
    }
  }
}
