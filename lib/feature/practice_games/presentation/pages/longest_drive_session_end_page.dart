import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/glassmorphism_card.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/header_row.dart';
import '../../../widget/session_view_button.dart';
import '../bloc/practice_games_bloc.dart';
import '../bloc/practice_games_event.dart';
import '../bloc/practice_games_state.dart';
import '../widgets/metric_display.dart';

class LongestDriveSessionEndPage extends StatelessWidget {
  const LongestDriveSessionEndPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PracticeGamesBloc, PracticeGamesState>(
      builder: (context, state) {
        final bestShot = state.bestShot;

        final allMetrics = [
          {
            "metric": "Total Distance",
            "value": bestShot?.totalDistance.toStringAsFixed(2),
            "unit": "YDS",
          },
          {
            "metric": "Ball Speed",
            "value": bestShot?.ballSpeed.toStringAsFixed(2),
            "unit": "MPH",
          },
        ];

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
                ),
                const SizedBox(height: 10),
                Image.asset(AppImages.trophyImage),
                MetricDisplay(
                  value: bestShot!.carryDistance.toStringAsFixed(2),
                  label: "Carry Distance",
                  unit: "YDS",
                ),
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 40,
                    childAspectRatio: 1.42,
                  ),
                  itemCount: allMetrics.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GlassmorphismCard(
                      value: allMetrics[index]["value"]!,
                      name: allMetrics[index]["metric"]!,
                      unit: allMetrics[index]["unit"]!,
                    );
                  },
                ),
                const Spacer(),
                SessionViewButton(
                  onSessionClick: () {
                    context
                        .read<PracticeGamesBloc>()
                        .add(StopListeningToBleDataEvent());
                    Navigator.pop(context);
                  },
                  buttonText: "Start New",
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }
}
