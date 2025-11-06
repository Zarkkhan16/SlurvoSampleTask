import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:intl/intl.dart';

import '../../../golf_device/presentation/pages/session_summary_screen.dart';
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
          // Re-taking club OR moving to next club, pop back to recording
          Navigator.pop(context);
        } else if (state is SessionSummaryState) {
          // Move to session summary (last club completed)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ClubGappingBloc>(),
                child: SessionSummaryScreen(summaryData: {},),
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

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: CustomAppBar(),
          body: Column(
            children: [
              // Club Name
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  clubSummary.club.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Shots List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: shots.length,
                  itemBuilder: (context, index) {
                    final shot = shots[index];
                    return _buildShotItem(shot, context);
                  },
                ),
              ),

              // Average Carry Distance
              Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      clubSummary.averageCarryDistance.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Average Carry Distance (Yds)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Re-Take Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ClubGappingBloc>().add(
                                RetakeCurrentClubEvent(),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Re-Take ${clubSummary.club.name} Gapping',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Move to Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (state.hasNextClub) {
                            context.read<ClubGappingBloc>().add(
                                  MoveToNextClubEvent(),
                                );
                            Navigator.pop(context);
                          } else {
                            context.read<ClubGappingBloc>().add(
                                  CompleteSessionEvent(),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          state.hasNextClub
                              ? 'Move to next club'
                              : 'View Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShotItem(ShotEntity shot, BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final timeString = timeFormat.format(shot.timestamp).toLowerCase();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Golf Ball Icon
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

          // Shot Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shot ${shot.shotNumber}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < shot.starRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '${shot.ballSpeed.toStringAsFixed(1)} mph',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '${shot.carryDistance.toStringAsFixed(1)} yds',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trophy Icon (optional, for best shot)
          if (shot.starRating >= 4)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
