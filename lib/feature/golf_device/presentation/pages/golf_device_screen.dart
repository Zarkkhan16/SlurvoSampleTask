import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/core/di/injection_container.dart' as di;
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_bloc.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_event.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_state.dart';
import 'package:onegolf/feature/golf_device/presentation/pages/session_summary_screen.dart';
import 'package:onegolf/feature/shots_history/presentation/pages/shot_history_screen.dart';
import 'package:onegolf/feature/widget/action_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../choose_club_screen/model/club_model.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/glassmorphism_card.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/custom_bar.dart';
import '../../../widget/header_row.dart';
import '../../../setting/persentation/pages/setting_screen.dart';
import 'dispersion_screen.dart';
import 'metric_filter_screen.dart';

class GolfDeviceView extends StatefulWidget {
  const GolfDeviceView({super.key});

  @override
  State<GolfDeviceView> createState() => _GolfDeviceViewState();
}

class _GolfDeviceViewState extends State<GolfDeviceView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GolfDeviceBloc, GolfDeviceState>(
      listener: (context, state) async {
        if (state is ClubUpdatedState) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       "Club updated",
          //       style: AppTextStyle.roboto(
          //         color: Colors.black,
          //       ),
          //     ),
          //     backgroundColor: Colors.white,
          //   ),
          // );
        } else if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is NavigateToSessionSummaryState) {


          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionSummaryScreen(
                summaryData: state.summaryData,
              ),
            ),
          );

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => SessionSummaryScreen(
          //       summaryData: state.summaryData,
          //     ),
          //   ),
          // );
        } else if (state is SaveShotsSuccessfully) {

          print("session number");
          print(context.read<GolfDeviceBloc>().currentSessionNumber);
          final sessionNumber = context.read<GolfDeviceBloc>().currentSessionNumber;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<GolfDeviceBloc>(),
                child: ShotHistoryScreen(sessionNumber: sessionNumber,),
              ),
            ),
          );

          if (result == 'connected') {
            final currentState = context.read<GolfDeviceBloc>().state;
            if (currentState is! ConnectedState) {
              context.read<GolfDeviceBloc>().add(ReturnToConnectedStateEvent());
            }
          }
        }
      },
      builder: (context, state) {
        if (state is DisconnectingState) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (state is SaveDataLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (state is ConnectedState) {
          return _buildConnectedScreen(context, state);
        } else {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
      },
    );
  }

  Widget _buildConnectedScreen(BuildContext context, ConnectedState state) {
    final allMetrics = [
      {
        "metric": "Club Speed",
        "value": state.golfData.clubSpeed.toStringAsFixed(1),
        "unit": "MPH"
      },
      {
        "metric": "Ball Speed",
        "value": state.golfData.ballSpeed.toStringAsFixed(1),
        "unit": "MPH"
      },
      {
        "metric": "Carry Distance",
        "value": state.golfData.carryDistance.toStringAsFixed(1),
        "unit": state.units ? "M" : "YDS"
      },
      {
        "metric": "Total Distance",
        "value": state.golfData.totalDistance.toStringAsFixed(1),
        "unit": state.units ? "M" : "YDS"
      },
      {
        "metric": "Smash Factor",
        "value": state.golfData.smashFactor.toString(),
        "unit": ""
      },
    ];

    final filteredMetrics = allMetrics
        .where((metric) => state.selectedMetrics.contains(metric["metric"]))
        .toList();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context
              .read<GolfDeviceBloc>()
              .add(DisconnectDeviceEvent());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        // bottomNavigationBar: BottomNavBar(),
        appBar: CustomAppBar(
          batteryLevel: state.golfData.battery,
          showSettingButton: true,
          showBatteryLevel: true,
          onSettingsPressed: () {
            context.read<GolfDeviceBloc>().add(PauseBleSyncEvent());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingScreen(
                  selectedUnit: state.units,
                ),
              ),
            ).then((_) {
              context.read<GolfDeviceBloc>().add(ResumeBleSyncEvent());
            });
          },
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Column(
                  children: [
                    HeaderRow(
                      showClubName: true,
                      goScanScreen: true,
                      headingName: "Shot Analysis",
                      selectedClub: Club(
                        code: state.golfData.clubName.toString(),
                        name: AppStrings.clubs[state.golfData.clubName],
                      ),
                      onClubSelected: (value) {
                        context.read<GolfDeviceBloc>().add(PauseBleSyncEvent());
                        context
                            .read<GolfDeviceBloc>()
                            .add(UpdateClubEvent(int.parse(value.code)));
                        context.read<GolfDeviceBloc>().add(ResumeBleSyncEvent());
                      },
                      backButtonHide: true,
                      onBackButton: () async {
                        context
                            .read<GolfDeviceBloc>()
                            .add(DisconnectDeviceEvent());
                      },
                    ),
                    SizedBox(height: 10),
                    CustomizeBar(
                      onPressed: () async {
                        final result = await Navigator.push<Set<String>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MetricFilterScreen(
                              initialSelectedMetrics: state.selectedMetrics,
                            ),
                          ),
                        );

                        if (result != null && result.isNotEmpty) {
                          context.read<GolfDeviceBloc>().add(
                                UpdateMetricFilterEvent(result),
                              );
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      state.currentDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    state.isLoading
                        ? Center(
                            child: CircularProgressIndicator(color: Colors.white))
                        : Expanded(
                            child: filteredMetrics.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.visibility_off,
                                          size: 48,
                                          color: Colors.white38,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No metrics selected',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap customize to select metrics',
                                          style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.42,
                                    ),
                                    itemCount: filteredMetrics.length,
                                    itemBuilder: (context, index) {
                                      return GlassmorphismCard(
                                        value: filteredMetrics[index]["value"]!,
                                        name: filteredMetrics[index]["metric"]!,
                                        unit: filteredMetrics[index]["unit"]!,
                                      );
                                    },
                                  ),
                          ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ActionButton(
                            text: AppStrings.deleteShotText,
                            onPressed: () {
                              context
                                  .read<GolfDeviceBloc>()
                                  .add(DeleteLatestShotEvent());
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ActionButton(
                            svgAssetPath: AppImages.groupIcon,
                            text: AppStrings.dispersionText,
                            onPressed: () {
                              final latestShot =
                                  context.read<GolfDeviceBloc>().latestShot;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<GolfDeviceBloc>(),
                                    child: DispersionScreen(
                                      selectedShot: latestShot,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ActionButton(
                            text: 'Session View',
                            onPressed: () {
                              context.read<GolfDeviceBloc>().add(PauseBleSyncEvent());
                              context
                                  .read<GolfDeviceBloc>()
                                  .add(SaveAllShotsEvent());
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ActionButton(
                            text: 'Session End',
                            buttonBackgroundColor: Colors.red,
                            textColor: AppColors.primaryText,
                            onPressed: () {
                              context
                                  .read<GolfDeviceBloc>()
                                  .add(DisconnectDeviceEvent());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
