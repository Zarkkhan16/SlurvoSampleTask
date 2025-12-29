import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

import '../../../widget/bottom_nav_bar.dart';
import '../bloc/club_gapping_bloc.dart';
import '../bloc/club_gapping_event.dart';
import '../bloc/club_gapping_state.dart';
import 'club_summary_page.dart';

class ShotRecordingScreen extends StatelessWidget {
  const ShotRecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClubGappingBloc, ClubGappingState>(
      listener: (context, state) {
        if (state is ClubSummaryState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: "ClubSummaryScreen"),
              builder: (_) => BlocProvider.value(
                value: context.read<ClubGappingBloc>(),
                child: ClubSummaryScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! RecordingShotsState) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final latestShot = state.latestShot;

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              context.read<ClubGappingBloc>().add(
                CompleteCurrentClubEvent(),
              );
            }
          },
          child: Scaffold(
          backgroundColor: Colors.black,
          appBar: CustomAppBar(),
          // bottomNavigationBar: BottomNavBar(),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              children: [
                HeaderRow(
                  headingName: "Club Gapping",
                  onBackButton: () {
                    context.read<ClubGappingBloc>().add(
                      CompleteCurrentClubEvent(),
                    );
                  },
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.currentClub.name,
                        style: AppTextStyle.oswald(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Shot ${state.currentShotNumber} of ${state.totalShots}',
                        style: AppTextStyle.oswald(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      latestShot != null
                          ? latestShot.carryDistance.toStringAsFixed(2)
                          : '0.00',
                      style: AppTextStyle.oswald(
                        fontSize: 65,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Carry Distance Yds',
                      style: AppTextStyle.roboto(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: [
                      _buildMetricCard(
                        value: latestShot != null
                            ? latestShot.clubSpeed.toStringAsFixed(1)
                            : '0.0',
                        label: 'Club Speed',
                        unit: 'MPH',
                      ),
                      _buildMetricCard(
                        value: latestShot != null
                            ? latestShot.ballSpeed.toStringAsFixed(1)
                            : '0.0',
                        label: 'Ball Speed',
                        unit: 'MPH',
                      ),
                      _buildMetricCard(
                        value: latestShot != null
                            ? latestShot.smashFactor.toStringAsFixed(2)
                            : '0.0',
                        label: 'Smash Factor',
                        unit: '',
                      ),
                      _buildMetricCard(
                        value: latestShot != null
                            ? latestShot.totalDistance.toStringAsFixed(1)
                            : '0',
                        label: 'Total Distance',
                        unit: 'Yds',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                if (latestShot != null)
                  SessionViewButton(
                    onSessionClick: () {
                      context.read<ClubGappingBloc>().add(
                        ReHitShotEvent(),
                      );
                    },
                    buttonText: "Re-Hit Shot",
                  ),
                // if (state.currentShotNumber >= state.totalShots) ...[
                //   SizedBox(height: 10),
                //   SessionViewButton(
                //     onSessionClick: () {
                //       context.read<ClubGappingBloc>().add(
                //             CompleteCurrentClubEvent(),
                //           );
                //     },
                //     buttonText: "Club Summary",
                //   ),
                // ],
                SizedBox(height: 10),
              ],
            ),
          ),
        ),);
      },
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required String unit,
  }) {
    return GradientBorderContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyle.oswald(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          Text(label,
              textAlign: TextAlign.center,
              style: AppTextStyle.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.2,
              )),
          if (unit.isNotEmpty) ...[
            Text(unit,
                style: AppTextStyle.roboto(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                )),
          ],
        ],
      ),
    );
  }
}
