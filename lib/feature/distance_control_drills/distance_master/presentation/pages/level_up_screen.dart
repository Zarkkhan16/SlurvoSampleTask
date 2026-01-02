import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_event.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_state.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/pages/session_complete_screen.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class LevelUpScreen extends StatelessWidget {
  const LevelUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(),
      // bottomNavigationBar: BottomNavBar(),
      body: BlocConsumer<DistanceMasterBloc, DistanceMasterState>(
        listener: (context, state) {
          if (state is SessionCompleteState) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => BlocProvider.value(
            //       value: context.read<DistanceMasterBloc>(),
            //       child: SessionCompleteScreen(),
            //     ),
            //   ),
            // );
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "SessionCompleteScreen"),
                builder: (_) => BlocProvider.value(
                  value: context.read<DistanceMasterBloc>(),
                  child: SessionCompleteScreen(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GameInProgressState) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (!didPop) {
                  context
                      .read<DistanceMasterBloc>()
                      .add(EndSessionEvent());
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Column(
                  children: [
                    HeaderRow(
                      headingName: "Level Up",
                      onBackButton: () {
                        context
                            .read<DistanceMasterBloc>()
                            .add(EndSessionEvent());
                      },
                    ),
                    Center(
                      child: Text(
                        'Hit three consecutive shots within the carry\ndistance window to level up',
                        style: AppTextStyle.roboto(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.targetDistance}',
                          style: AppTextStyle.oswald(
                            fontWeight: FontWeight.w700,
                            fontSize: 60,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'yds',
                            style: AppTextStyle.oswald(
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Text(
                        '${state.minDistance}-${state.maxDistance} yds',
                        style: AppTextStyle.oswald(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          _buildShotIndicator(
                            i < state.currentShots.length
                                ? (state.currentShots[i].isSuccess
                                    ? 'success'
                                    : 'fail')
                                : 'pending',
                          ),
                          if (i < 2) SizedBox(width: 10),
                        ],
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Level',
                      style: AppTextStyle.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${state.currentLevel}',
                      style: AppTextStyle.oswald(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (state.currentLevel < state.totalLevels)
                      Text(
                        'Next Level',
                        style: AppTextStyle.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (state.currentLevel < state.totalLevels)
                      Text(
                        '${state.targetDistance + state.incrementLevel} yds',
                        style: AppTextStyle.oswald(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    Spacer(),
                    GradientBorderContainer(
                      borderRadius: 16,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      containerWidth: double.infinity,
                      child: Column(
                        children: [
                          Text(
                            'Actual Carry',
                            style: AppTextStyle.roboto(
                              color: AppColors.secondaryText,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            state.currentShots.isEmpty
                                ? "0"
                                : state.currentShots.last.carryDistance.toString(),
                            style: AppTextStyle.oswald(
                              fontWeight: FontWeight.w700,
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            'yds',
                            style: AppTextStyle.roboto(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    SessionViewButton(
                      onSessionClick: () {
                        context
                            .read<DistanceMasterBloc>()
                            .add(EndSessionEvent());
                      },
                      buttonText: "End Session",
                    ),
                    SizedBox(height: 10),
                  ],
                ),
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

  Widget _buildShotIndicator(String status) {
    Color color;
    Color borderColor;

    switch (status) {
      case 'success':
        color = Colors.green;
        borderColor = Colors.green;
        break;
      case 'fail':
        color = Colors.red;
        borderColor = Colors.red;
        break;
      case 'pending':
      default:
        color = Colors.transparent;
        borderColor = Color(0xff6981A6);
        break;
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
    );
  }
}
