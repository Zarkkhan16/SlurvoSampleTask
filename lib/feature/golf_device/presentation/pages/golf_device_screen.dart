import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/golf_device/domain/entities/device_entity.dart';
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

class GolfDeviceView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GolfDeviceBloc, GolfDeviceState>(
      listener: (context, state) async {
        print("On Listener State Change");
        print(state);
        if (state is ClubUpdatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Club updated")),
          );
        } else if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ConnectedState && state != state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connected to ${state.device.name}')),
          );
        } else if (state is NavigateToSessionSummaryState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SessionSummaryScreen(
                summaryData: state.summaryData,
              ),
            ),
          );
        } else if (state is NavigateToLandDashboardState) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/landingDashboard',
            (route) => false,
          );
        } else if (state is SaveShotsSuccessfully) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<GolfDeviceBloc>(),
                child: const ShotHistoryScreen(),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Disconnecting device...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is SaveDataLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Save Data...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is ConnectedState) {
          return _buildConnectedScreen(context, state);
        } else {
          return _buildScanScreen(context, state);
        }
      },
    );
  }

  Widget _buildConnectedScreen(BuildContext context, ConnectedState state) {
    final allMetrics = [
      {
        "metric": "Club Speed",
        "value": state.golfData.clubSpeed.toStringAsFixed(2),
        "unit": "MPH"
      },
      {
        "metric": "Ball Speed",
        "value": state.golfData.ballSpeed.toStringAsFixed(2),
        "unit": "MPH"
      },
      {
        "metric": "Carry Distance",
        "value": state.golfData.carryDistance.toStringAsFixed(2),
        "unit": state.units ? "M" : "YDS"
      },
      {
        "metric": "Total Distance",
        "value": state.golfData.totalDistance.toStringAsFixed(2),
        "unit": state.units ? "M" : "YDS"
      },
      {
        "metric": "Smash Factor",
        "value": state.golfData.smashFactor.toStringAsFixed(2),
        "unit": ""
      },
    ];

    // Filter metrics based on selection
    final filteredMetrics = allMetrics
        .where((metric) => state.selectedMetrics.contains(metric["metric"]))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: BottomNavBar(),
      appBar: CustomAppBar(
        batteryLevel: state.golfData.battery,
        showSettingButton: true,
        showBatteryLevel: true,
        onSettingsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingScreen(
                connectedDevice: state.device,
                selectedUnit: state.units,
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      context
                          .read<GolfDeviceBloc>()
                          .add(UpdateClubEvent(int.parse(value.code)));
                    },
                    onBackButton: () async {
                      context
                          .read<GolfDeviceBloc>()
                          .add(DisconnectDeviceEvent());
                    },
                  ),
                  SizedBox(height: 14),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        state.currentDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        state.elapsedTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                                  padding: EdgeInsets.all(16),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 30,
                                    mainAxisSpacing: 20,
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
                      SizedBox(
                        width: 10,
                      ),
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
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          text: 'Session View',
                          onPressed: () {
                            context
                                .read<GolfDeviceBloc>()
                                .add(SaveAllShotsEvent());
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
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
    );
  }

  Widget _buildScanScreen(BuildContext context, GolfDeviceState state) {
    final isScanning = state is ScanningState;
    final isConnecting = state is ConnectingState;
    final devices = state is ScanningState
        ? state.devices
        : state is DevicesFoundState
            ? state.devices
            : state is ConnectingState
                ? state.devices
                : state is DisconnectedState
                    ? state.devices
                    : <DeviceEntity>[];

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BottomNavBar(),
      appBar: CustomAppBar(
        showSettingButton: true,
        rightTopIcon: Icons.refresh,
        onSettingsPressed: () {
          context.read<GolfDeviceBloc>().add(StartScanningEvent());
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderRow(headingName: "Scan Devices"),
            const SizedBox(height: 12),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isScanning || isConnecting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (devices.isEmpty) {
                    return const Center(
                      child: Text(
                        "No devices found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading:
                              const Icon(Icons.bluetooth, color: Colors.green),
                          title: Text(
                            device.name.isNotEmpty
                                ? device.name
                                : "Unknown Device",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Signal: ${device.rssi} dBm",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            context
                                .read<GolfDeviceBloc>()
                                .add(ConnectToDeviceEvent(device));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
