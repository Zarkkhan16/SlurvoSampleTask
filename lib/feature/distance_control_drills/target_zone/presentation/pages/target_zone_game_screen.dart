import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/bottom_controller.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_event.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_state.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/pages/target_zone_session_summary_screen.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/widgets/state_box_widget.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/widgets/state_row_widget.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class TargetZoneGameScreen extends StatefulWidget {
  const TargetZoneGameScreen({super.key});

  @override
  State<TargetZoneGameScreen> createState() => _TargetZoneGameScreenState();
}

class _TargetZoneGameScreenState extends State<TargetZoneGameScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<TargetZoneBloc, TargetZoneState>(
      listener: (context, state) {
        if (state is TargetZoneSessionCompleteState) {
          final bloc = context.read<TargetZoneBloc>(); // ✅ capture first

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const TargetZoneSessionSummaryScreen(),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<TargetZoneBloc, TargetZoneState>(
        builder: (context, state) {
          if (state is! TargetZoneGameState) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (!didPop) {
                context.read<TargetZoneBloc>().add(const FinishSessionEvent());
              }
            },
            child: Scaffold(
              appBar: CustomAppBar(),
              // bottomNavigationBar: BottomNavBar(),
              backgroundColor: AppColors.primaryBackground,
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                child: Column(
                  children: [
                    HeaderRow(
                      headingName: "Target Zone",
                      onBackButton: () {
                        context
                            .read<TargetZoneBloc>()
                            .add(const FinishSessionEvent());
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
                        "Target Carry Distance",
                        style: AppTextStyle.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatRowWidget(
                      label1: 'Attempts',
                      value1: '${state.totalAttempts}',
                      label2: 'Attempts within Target',
                      value2: '${state.attemptsWithinTarget}',
                    ),
                    const SizedBox(height: 16),
                    StatBoxWidget(
                      label: 'Success Rate',
                      value: '${state.successRate.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 16),
                    StatBoxWidget(
                      label: 'Target Carry',
                      value: '${state.targetDistance} yds',
                      toleranceValue:
                      "${state.targetDistance - state.tolerance} - ${state.targetDistance + state.tolerance} yds",
                      showTargetTolerance: true,
                    ),
                    const SizedBox(height: 16),
                    StatBoxWidget(
                      label: 'Actual Carry',
                      value: '${state.lastActualCarry ?? 0} yds',
                      isGreen: state.isLastShotWithinTarget,
                      showColor: state.lastActualCarry == null ? false : true,
                    ),
                    Spacer(),
                    SessionViewButton(
                      onSessionClick: () {
                        context
                            .read<TargetZoneBloc>()
                            .add(const FinishSessionEvent());
                      },
                      buttonText: "Finish Session",
                    ),
                    const SizedBox(height: 20),
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
