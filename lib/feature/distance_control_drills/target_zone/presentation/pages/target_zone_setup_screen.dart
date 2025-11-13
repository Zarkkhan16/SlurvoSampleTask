import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/data/model/target_zone_config.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_event.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_state.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/pages/target_zone_game_screen.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class TargetZoneSetupScreen extends StatefulWidget {
  const TargetZoneSetupScreen({super.key});

  @override
  State<TargetZoneSetupScreen> createState() => _TargetZoneSetupScreenState();
}

class _TargetZoneSetupScreenState extends State<TargetZoneSetupScreen> {
  bool _navigatedToLevelUp = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TargetZoneBloc, TargetZoneState>(
      listener: (context, state) {
        if (state is TargetZoneGameState) {
          // _navigatedToLevelUp = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TargetZoneBloc>(),
                child: TargetZoneGameScreen(),
              ),
            ),
          );
          //     .then((_) {
          //   _navigatedToLevelUp = false;
          // });
        } else if (state is TargetZoneErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is! TargetZoneSetupState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(),
          backgroundColor: AppColors.primaryBackground,
          bottomNavigationBar: BottomNavBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
            child: Column(
              children: [
                HeaderRow(headingName: "Target Zone",),
                Text(
                  "Hone in on carry distance. Pure repetition.\nPure mastery",
                  style: AppTextStyle.roboto(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildSectionTitle('Target Carry Distance'),
                const SizedBox(height: 10),
                _buildDistanceDisplay(state.targetDistance),
                _buildDistanceSlider(context, state),
                const SizedBox(height: 25),
                _buildSectionTitle('Difficulty Level'),
                const SizedBox(height: 10),
                _buildDifficultyButtons(context, state),
                const SizedBox(height: 25),
                _buildSectionTitle('Shot Count'),
                _buildShotCountSlider(context, state),
                const SizedBox(height: 25),
                _buildUnlimitedCheckbox(context, state),
                Spacer(),
                SessionViewButton(
                  onSessionClick: () {
                    final config = TargetZoneConfig(
                      targetDistance: state.targetDistance,
                      difficulty: state.difficulty,
                      totalShots: state.shotCount,
                    );

                    context.read<TargetZoneBloc>().add(StartGameEvent(config));
                  },
                  buttonText: "Start Drill",
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        title,
        style: AppTextStyle.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDistanceDisplay(int distance) {
    return GradientBorderContainer(
      borderRadius: 20,
      containerWidth: double.infinity,
      child: Text(
        '$distance yds',
        style: AppTextStyle.oswald(
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDistanceSlider(
    BuildContext context,
    TargetZoneSetupState state,
  ) {
    const minDistance = 60;
    const maxDistance = 150;
    return SfSliderTheme(
      data: SfSliderThemeData(
        activeLabelStyle:
            AppTextStyle.roboto(fontWeight: FontWeight.w500, fontSize: 16),
        inactiveLabelStyle: AppTextStyle.roboto(),
      ),
      child: SfSlider(
        activeColor: AppColors.primaryText,
        inactiveColor: AppColors.dividerColor,
        min: minDistance.toDouble(),
        max: maxDistance.toDouble(),
        value: state.targetDistance.toDouble(),
        interval: 15,
        showLabels: true,
        showDividers: true,
        onChanged: (dynamic value) {
          context.read<TargetZoneBloc>().add(
                TargetDistanceChanged(value.toInt()),
              );
        },
      ),
    );
  }

  Widget _buildDifficultyButtons(
    BuildContext context,
    TargetZoneSetupState state,
  ) {
    return Row(
      children: [
        _buildDifficultyButton(
          context,
          label: 'Easy',
          subtitle: '7 yds',
          difficulty: 7,
          isSelected: state.difficulty == 7,
        ),
        SizedBox(width: 10),
        _buildDifficultyButton(
          context,
          label: 'Medium',
          subtitle: '5 yds',
          difficulty: 5,
          isSelected: state.difficulty == 5,
        ),
        SizedBox(width: 10),
        _buildDifficultyButton(
          context,
          label: 'Hard',
          subtitle: '3 yds',
          difficulty: 3,
          isSelected: state.difficulty == 3,
        ),
      ],
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required int difficulty,
    required bool isSelected,
  }) {
    Color backgroundColor = isSelected ? Colors.white : const Color(0xFF2A2A2A);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<TargetZoneBloc>().add(DifficultyChanged(difficulty));
        },
        child: GradientBorderContainer(
          borderRadius: 16,
          backgroundColor: backgroundColor,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyle.roboto(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyle.oswald(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShotCountSlider(
    BuildContext context,
    TargetZoneSetupState state,
  ) {
    final displayValue = state.shotCount == -1 ? 10 : state.shotCount;
    return SfSliderTheme(
      data: SfSliderThemeData(
        activeLabelStyle:
            AppTextStyle.roboto(fontWeight: FontWeight.w500, fontSize: 16),
        inactiveLabelStyle: AppTextStyle.roboto(),
      ),
      child: SfSlider(
        activeColor: AppColors.primaryText,
        inactiveColor: AppColors.dividerColor,
        min: 1,
        max: 10,
        value: displayValue,
        interval: 1,
        showLabels: true,
        showDividers: true,
        onChanged: (dynamic value) {
          context.read<TargetZoneBloc>().add(
                ShotCountChanged(value.toInt()),
              );
        },
      ),
    );
  }

  Widget _buildUnlimitedCheckbox(
    BuildContext context,
    TargetZoneSetupState state,
  ) {
    final isUnlimited = state.shotCount == -1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          context.read<TargetZoneBloc>().add(
                ShotCountChanged(isUnlimited ? 10 : -1),
              );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unlimited Shots',
              style: AppTextStyle.roboto(),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  color: isUnlimited
                      ? AppColors.primaryText
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isUnlimited
                        ? AppColors.primaryText
                        : AppColors.dividerColor,
                    width: 1,
                  )),
              child: Icon(
                isUnlimited ? Icons.check : null,
                color: Colors.black,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
