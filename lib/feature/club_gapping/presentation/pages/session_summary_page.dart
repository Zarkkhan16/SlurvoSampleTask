import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/bottom_controller.dart';
import 'package:onegolf/feature/club_gapping/presentation/pages/shot_recording_page.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

import '../bloc/club_gapping_bloc.dart';
import '../bloc/club_gapping_event.dart';
import '../bloc/club_gapping_state.dart';

class SessionSummaryPage extends StatelessWidget {
  const SessionSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClubGappingBloc, ClubGappingState>(
      listener: (context, state) {
        if (state is RecordingShotsState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: "ShotRecordingScreen"),
              builder: (_) => BlocProvider.value(
                value: context.read<ClubGappingBloc>(),
                child: ShotRecordingScreen(),
              ),
            ),
            (route) => route.settings.name == "ClubSelectionScreen",
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

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              // context.read<ClubGappingBloc>().add(
              //       SaveSessionEvent(),
              //     );
              //
              // Navigator.popUntil(
              //   context,
              //   (route) => route.settings.name == "PracticeGamesScreen",
              // );

              final bloc = context.read<ClubGappingBloc>();

              bloc.add(SaveSessionEvent());

              // 1️⃣ Exit the gapping flow safely
              Navigator.of(context).popUntil(
                    (route) => route.isFirst,
              );

              // 2️⃣ Switch tab AFTER pop completes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                BottomNavController.goToTab(2); // Practice Games
              });
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: CustomAppBar(),
            // bottomNavigationBar: BottomNavBar(),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
              child: Column(
                children: [
                  HeaderRow(
                    headingName: "Club Gapping Summary",
                    onBackButton: () {
                      // context.read<ClubGappingBloc>().add(
                      //       SaveSessionEvent(),
                      //     );
                      //
                      // Navigator.popUntil(
                      //   context,
                      //   (route) => route.settings.name == "PracticeGamesScreen",
                      // );

                      final bloc = context.read<ClubGappingBloc>();

                      bloc.add(SaveSessionEvent());

                      // 1️⃣ Exit the gapping flow safely
                      Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                      );

                      // 2️⃣ Switch tab AFTER pop completes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        BottomNavController.goToTab(2); // Practice Games
                      });

                    },
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: GradientBorderContainer(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Club',
                                  style: AppTextStyle.oswald(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Carry Yds',
                                  textAlign: TextAlign.right,
                                  style: AppTextStyle.oswald(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: AppColors.dividerColor,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: clubSummaries.length,
                              itemBuilder: (context, index) {
                                final summary = clubSummaries[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          summary.club.name,
                                          style: AppTextStyle.oswald(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          summary.averageCarryDistance
                                              .toStringAsFixed(0),
                                          textAlign: TextAlign.right,
                                          style: AppTextStyle.oswald(
                                            fontSize: 16,
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
                  SizedBox(height: 30),
                  SessionViewButton(
                    onSessionClick: () => context.read<ClubGappingBloc>().add(
                          RetakeSessionEvent(),
                        ),
                    buttonText: "Re-Take Gapping Session",
                  ),
                  SizedBox(height: 10),
                  SessionViewButton(
                    onSessionClick: () {
                      // context.read<ClubGappingBloc>().add(
                      //       SaveSessionEvent(),
                      //     );
                      // BottomNavController.goToTab(0);
                      // // Navigator.popUntil(
                      // //   context,
                      // //   (route) => route.settings.name == "PracticeGamesScreen",
                      // // );

                      final bloc = context.read<ClubGappingBloc>();

                      bloc.add(SaveSessionEvent());

                      // 1️⃣ Exit the gapping flow safely
                      Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                      );

                      // 2️⃣ Switch tab AFTER pop completes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        BottomNavController.goToTab(2); // Practice Games
                      });
                    },
                    buttonText: "Done",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
