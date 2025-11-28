import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_bloc.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/header_row.dart';
import '../../../widget/session_view_button.dart';
import '../bloc/practice_games_event.dart';
import '../widgets/metric_display.dart';
import 'longest_drive_session_end_page.dart';

class LongestDriveSessionPage extends StatelessWidget {
  final int totalShots;

  const LongestDriveSessionPage({super.key, required this.totalShots});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PracticeGamesBloc, PracticeGamesState>(
      listener: (context, state) {
        if (state.sessionCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<PracticeGamesBloc>(),
                child: LongestDriveSessionEndPage(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        print("sssss");
        print(state.sessionCompleted);
        String getSafeValue(double Function() valueGetter) {
          final index = state.currentAttempt - 1;
          if (state.latestBleData.isEmpty || index < 0 || index >= state.latestBleData.length) {
            return '0.00';
          }
          return valueGetter().toStringAsFixed(1);
        }

        final carryDistance = getSafeValue(() => state.latestBleData[state.currentAttempt - 1].carryDistance);
        final totalDistance = getSafeValue(() => state.latestBleData[state.currentAttempt - 1].totalDistance);
        final ballSpeed = getSafeValue(() => state.latestBleData[state.currentAttempt - 1].ballSpeed);

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: CustomAppBar(),
          bottomNavigationBar: BottomNavBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              children: [
                HeaderRow(
                  headingName: "Longest Drive",
                  onBackButton: () {
                    context
                        .read<PracticeGamesBloc>()
                        .add(StopListeningToBleDataEvent());
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 10),
                Text(
                  "Attempt ${state.currentAttempt} of $totalShots",
                  style: AppTextStyle.roboto(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                MetricDisplay(value: ballSpeed, label: "Ball Speed", unit: "MPH"),
                MetricDisplay(
                    value: carryDistance, label: "Carry Distance", unit: "YDS"),
                MetricDisplay(
                    value: totalDistance, label: "Total Distance", unit: "YDS"),
                const Spacer(),
                SessionViewButton(
                  onSessionClick: () {
                      context.read<PracticeGamesBloc>().add(SessionEndAttemptEvent());
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<PracticeGamesBloc>(context),
                            child: LongestDriveSessionEndPage(),
                          ),
                        ),
                      );
                  },
                  buttonText: "End Session",
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
