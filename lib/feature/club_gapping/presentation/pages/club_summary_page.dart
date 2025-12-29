import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/club_gapping/presentation/pages/session_summary_page.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';
import '../../domain/entities/shot_entity.dart';
import '../bloc/club_gapping_bloc.dart';
import '../bloc/club_gapping_event.dart';
import '../bloc/club_gapping_state.dart';

class ClubSummaryScreen extends StatelessWidget {
  const ClubSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClubGappingBloc, ClubGappingState>(
      listener: (context, state) {
        if (state is RecordingShotsState) {
          Navigator.pop(context);
        } else if (state is SessionSummaryState) {
          final bloc = context.read<ClubGappingBloc>();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: "SessionSummaryScreen"),
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const SessionSummaryPage(),
              ),
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        return current is ClubSummaryState;
      },
      builder: (context, state) {
        if (state is! ClubSummaryState) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final clubSummary = state.clubSummary;
        final shots = clubSummary.shots;

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              context.read<ClubGappingBloc>().add(
                    CompleteSessionEvent(),
                  );
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: CustomAppBar(),
            // bottomNavigationBar: BottomNavBar(),
            body: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                  child: HeaderRow(
                    headingName: "Club Summary",
                    onBackButton: () {
                      context.read<ClubGappingBloc>().add(
                            CompleteSessionEvent(),
                          );
                    },
                  ),
                ),
                SizedBox(height: 5),
                Text(clubSummary.club.name,
                    style: AppTextStyle.oswald(
                      fontSize: 28,
                    )),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: shots.length,
                    itemBuilder: (context, index) {
                      final shot = shots[index];
                      return _buildShotItem(shot, context);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: const Border(
                      top: BorderSide(color: Colors.white, width: 0.7),
                      left: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: GradientBorderContainer(
                          containerHeight: 140,
                          containerWidth: 200,
                          child: Column(
                            children: [
                              Text(
                                clubSummary.averageCarryDistance
                                    .toStringAsFixed(1),
                                style: AppTextStyle.oswald(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 68,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Average Carry\nDistance (Yds)',
                                style: AppTextStyle.roboto(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SessionViewButton(
                        onSessionClick: () {
                          context.read<ClubGappingBloc>().add(
                                RetakeCurrentClubEvent(),
                              );
                        },
                        buttonText: 'Re-Take ${clubSummary.club.name} Gapping',
                      ),
                      SizedBox(height: 10),
                      SessionViewButton(
                        onSessionClick: () {
                          if (state.hasNextClub) {
                            context.read<ClubGappingBloc>().add(
                                  MoveToNextClubEvent(),
                                );
                          } else {
                            context.read<ClubGappingBloc>().add(
                                  CompleteSessionEvent(),
                                );
                          }
                        },
                        buttonText: state.hasNextClub
                            ? 'Move to next club'
                            : 'View Summary',
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShotItem(ShotEntity shot, BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final timeString = timeFormat.format(shot.timestamp).toLowerCase();

    return GradientBorderContainer(
      borderRadius: 20,
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.sports_golf,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shot ${shot.shotNumber}',
                      style: AppTextStyle.oswald(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${shot.ballSpeed.toStringAsFixed(1)} mph',
                      style: AppTextStyle.oswald(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${shot.carryDistance.toStringAsFixed(1)} yds',
                      style: AppTextStyle.oswald(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 5),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeString,
                      style: AppTextStyle.oswald(),
                    ),
                    Text(
                      'Ball Speed',
                      style: AppTextStyle.oswald(),
                    ),
                    Text(
                      'Carry Distance',
                      style: AppTextStyle.oswald(),
                    ),
                    SizedBox(width: 5),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
