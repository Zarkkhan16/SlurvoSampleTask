import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/club_gapping/presentation/pages/shot_recording_page.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';

import '../bloc/club_gapping_bloc.dart';
import '../bloc/club_gapping_event.dart';
import '../bloc/club_gapping_state.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClubGappingBloc, ClubGappingState>(
      listener: (context, state) {
        if (state is RecordingShotsState) {
          // Re-taking session, navigate back
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ClubGappingBloc>(),
                child: ShotRecordingScreen(),
              ),
            ),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is! SessionSummaryState) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final clubSummaries = state.clubSummaries;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: CustomAppBar(),
          body: Column(
            children: [
              // Summary Table
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white10,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Club',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Carry Yds',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Rows
                      Expanded(
                        child: ListView.builder(
                          itemCount: clubSummaries.length,
                          itemBuilder: (context, index) {
                            final summary = clubSummaries[index];
                            final isLast = index == clubSummaries.length - 1;

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : Border(
                                        bottom: BorderSide(
                                          color: Colors.white10,
                                          width: 1,
                                        ),
                                      ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      summary.club.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      summary.averageCarryDistance
                                          .toStringAsFixed(0),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Re-Take Gapping Session Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ClubGappingBloc>().add(
                                RetakeSessionEvent(),
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
                          'Re-Take Gapping Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Done Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Save session if needed
                          context.read<ClubGappingBloc>().add(
                                SaveSessionEvent(),
                              );

                          // Exit to dashboard
                          Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
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
                          'Done',
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
}
