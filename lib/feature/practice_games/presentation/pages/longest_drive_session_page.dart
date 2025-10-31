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
    return BlocBuilder<PracticeGamesBloc, PracticeGamesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: CustomAppBar(),
          bottomNavigationBar: BottomNavBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              children: [
                HeaderRow(headingName: "Longest Drive"),
                SizedBox(height: 10),
                Text(
                  "Attempt ${state.currentAttempt} of $totalShots",
                  style: AppTextStyle.roboto(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                MetricDisplay(value: "0.00", label: "Carry Distance", unit: "YDS"),
                MetricDisplay(value: "0.00", label: "Total Distance", unit: "YDS"),
                MetricDisplay(value: "0.00", label: "Ball Speed", unit: "MPH"),
                const Spacer(),
                SessionViewButton(
                  onSessionClick: () {
                    if (state.currentAttempt < totalShots) {
                      context.read<PracticeGamesBloc>().add(NextAttemptEvent());
                    } else {
                      context.read<PracticeGamesBloc>().add(ResetSessionEvent());
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LongestDriveSessionEndPage(),
                        ),
                      );
                    }
                  },
                  buttonText: state.currentAttempt == totalShots ? "End Session" : "Next",
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