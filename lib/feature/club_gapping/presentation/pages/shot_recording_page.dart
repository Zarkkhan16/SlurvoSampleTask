import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';

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

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: CustomAppBar(),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Club Name and Shot Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.currentClub.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Shot ${state.currentShotNumber} of ${state.totalShots}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // Large Carry Distance Display
                Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        latestShot != null
                            ? latestShot.carryDistance.toStringAsFixed(2)
                            : '0.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Carry Distance Yds',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Metrics Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
                            ? latestShot.smashFactor.toStringAsFixed(1)
                            : '0.0',
                        label: 'Smash Factor',
                        unit: '',
                      ),
                      _buildMetricCard(
                        value: latestShot != null
                            ? latestShot.totalDistance.toStringAsFixed(0)
                            : '0',
                        label: 'Total Distance',
                        unit: 'Yds',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Re-Hit Shot Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: latestShot != null
                        ? () {
                            context.read<ClubGappingBloc>().add(
                                  ReHitShotEvent(),
                                );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          latestShot != null ? Colors.white : Colors.grey[800],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      disabledBackgroundColor: Colors.grey[800],
                      disabledForegroundColor: Colors.grey[600],
                    ),
                    child: Text(
                      'Re-Hit Shot',
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
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required String unit,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (unit.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              unit,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
