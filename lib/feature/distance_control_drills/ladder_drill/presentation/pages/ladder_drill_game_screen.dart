import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_state.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_event.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/widgets/state_box_widget.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class LadderDrillGameScreen extends StatelessWidget {
  const LadderDrillGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: BlocConsumer<LadderDrillBloc, LadderDrillState>(
        listener: (context, state) {
          if (state is LevelCompleteState) {
            // 5 second delay then show congratulations
            Future.delayed(Duration(seconds: 5), () {
              _showCongratulationsDialog(context, state.nextTargetDistance);
            });
          } else if (state is SessionCompleteState) {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => LadderDrillSessionCompleteScreen(),
            //   ),
            // );
          }
        },
        builder: (context, state) {
          if (state is GameInProgressState) {
            return _buildGameProgress(context, state);
          } else if (state is LevelCompleteState) {
            return _buildLevelSuccess(context, state);
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildGameProgress(BuildContext context, GameInProgressState state) {
    final shotStatus =
        state.currentShots.isNotEmpty ? state.currentShots.last : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
      child: Column(
        children: [
          HeaderRow(
            headingName: "Ladder Drill",
          ),
          Center(
            child: Text(
              'Hit the ball within the target zone to progress\nto the next level. Complete the ladder drill in\nas few shots as possible.',
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
          SizedBox(height: 30),
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
          // Next Level Info
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

          SizedBox(height: 50),
          StatBoxWidget(
            label: 'Actual Carry',
            value: '${state.lastActualCarry ?? 0}',
            showYdsDown: true,
            isGreen: state.isLastShotWithinTarget,
            showColor: state.lastActualCarry == null ? false : true,
          ),
          Spacer(),
          SessionViewButton(
            onSessionClick: () {
              context.read<LadderDrillBloc>().add(EndSessionEvent());
            },
            buttonText: "End Session",
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLevelSuccess(BuildContext context, LevelCompleteState state) {
    // This shows for 5 seconds after successful shot
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Success!',
            style: AppTextStyle.oswald(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            'Shot within target zone',
            style: AppTextStyle.roboto(
              fontSize: 16,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 10),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(height: 10),
          Text(
            'Loading next level...',
            style: AppTextStyle.roboto(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  void _showCongratulationsDialog(BuildContext context, int nextDistance) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Congratulations',
                style: AppTextStyle.oswald(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "You've reached the next level",
                style: AppTextStyle.roboto(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Next Level',
                style: AppTextStyle.roboto(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                '$nextDistance yd',
                style: AppTextStyle.oswald(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<LadderDrillBloc>().add(NextLevelEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppTextStyle.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
