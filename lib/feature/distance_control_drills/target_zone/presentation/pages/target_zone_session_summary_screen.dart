import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_event.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_state.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/pages/target_zone_setup_screen.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/widgets/state_box_widget.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/widgets/state_row_widget.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class TargetZoneSessionSummaryScreen extends StatelessWidget {
  const TargetZoneSessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TargetZoneBloc, TargetZoneState>(
      listener: (context, state) {
        if (state is TargetZoneGameState) {}
      },
      child: BlocBuilder<TargetZoneBloc, TargetZoneState>(
        builder: (context, state) {
          if (state is! TargetZoneSessionCompleteState) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          print('📄 Summary Screen Data:');
          print('   Total Attempts: ${state.session.totalAttempts}');
          print('   Within Target: ${state.session.attemptsWithinTarget}');
          print('   Success Rate: ${state.session.successRate}%');
          print('   Target Distance: ${state.session.config.targetDistance}');
          print('   Difficulty: ${state.session.config.difficulty}');

          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              context.read<TargetZoneBloc>().add(const ResetGameEvent());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<TargetZoneBloc>(),
                    child: TargetZoneSetupScreen(),
                  ),
                ),
              );
            },
            child: Scaffold(
              appBar: CustomAppBar(),
              bottomNavigationBar: BottomNavBar(),
              backgroundColor: AppColors.primaryBackground,
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                child: Column(
                  children: [
                    HeaderRow(
                      headingName: "Target Zone",
                      onBackButton: (){
                        context.read<TargetZoneBloc>().add(const ResetGameEvent());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<TargetZoneBloc>(),
                              child: TargetZoneSetupScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      "Hone in on carry distance. Pure repetition.\nPure mastery",
                      style: AppTextStyle.roboto(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Session Summary",
                        style: AppTextStyle.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    StatRowWidget(
                      label1: 'Attempts',
                      value1: '${state.session.totalAttempts}',
                      label2: 'Attempts within Target',
                      value2: '${state.session.attemptsWithinTarget}',
                    ),
                    const SizedBox(height: 16),
                    StatBoxWidget(
                      label: 'Success Rate',
                      value: '${state.session.successRate.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 16),
                    StatBoxWidget(
                      label: 'Target Carry',
                      value: '${state.session.config.targetDistance} yds',
                      toleranceValue:
                      "${state.session.config.targetDistance - (state.session.config.difficulty ~/ 2)} - ${state.session.config.targetDistance + (state.session.config.difficulty ~/ 2)} yds",
                      showTargetTolerance: true,
                    ),
                    Spacer(),
                    SessionViewButton(
                      onSessionClick: () {
                        context.read<TargetZoneBloc>().add(const ResetGameEvent());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<TargetZoneBloc>(),
                              child: TargetZoneSetupScreen(),
                            ),
                          ),
                        );
                      },
                      buttonText: "Restart Session",
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
