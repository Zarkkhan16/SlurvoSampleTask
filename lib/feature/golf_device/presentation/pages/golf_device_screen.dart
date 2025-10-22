import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/golf_device/domain/entities/device_entity.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/connect_device_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/disconnect_device_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/discover_services_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/scan_devices_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/send_command_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/send_sync_packet_usecase.dart';
import 'package:onegolf/feature/golf_device/domain/usecases/subscribe_notifications_usecase.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_bloc.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_event.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_state.dart';
import 'package:onegolf/feature/golf_device/presentation/pages/shot_history_screen.dart';
import 'package:onegolf/feature/home_screens/presentation/widgets/buttons/action_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../choose_club_screen/presentation/choose_club_screen_page.dart';
import '../../../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import '../../../home_screens/presentation/widgets/buttons/session_view_button.dart';
import '../../../home_screens/presentation/widgets/card/glassmorphism_card.dart';
import '../../../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import '../../../home_screens/presentation/widgets/custom_bar/custom_bar.dart';
import '../../../home_screens/presentation/widgets/header/header_row.dart';
import '../../../setting/persentation/pages/setting_screen.dart';
import '../../domain/repositories/ble_repository.dart';
import '../widgets/session_end_dialog.dart';

class GolfDeviceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<GolfDeviceBloc>(),
      child: GolfDeviceView(),
    );
  }
}

class GolfDeviceView extends StatelessWidget {
  static const List<String> _clubs = [
    "1W",
    "2W",
    "3W",
    "5W",
    "7W",
    "2H",
    "3H",
    "4H",
    "5H",
    "1i",
    "2i",
    "3i",
    "4i",
    "5i",
    "6i",
    "7i",
    "8i",
    "9i",
    "PW",
    "GW",
    "GW1",
    "SW",
    "SW1",
    "LW",
    "LW1"
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GolfDeviceBloc, GolfDeviceState>(
      listener: (context, state) async {
        print("{{{{{{{{{{");
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
        } else if (state is NavigateToLandDashboardState) {
          print("navigate to landing dashboard");
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/landingDashboard',
            (route) => false,
          );
        } else if (state is GolfDeviceSaveSuccessState){
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
              print("lsdkkljaskldfjasjflaskljf;klas");
              print(currentState);
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
        if (state is GolfDeviceSaveDataLoading){
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
        }
        if (state is ShotRecordsLoadedState) {
          if (state.shotRecords.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.golf_course, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No shots recorded yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.shotRecords.length,
            itemBuilder: (context, index) {
              final shot = state.shotRecords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shot #${shot['shotNumber']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text(AppStrings.getClub(shot['clubName'])),
                            backgroundColor: Colors.green.shade100,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              label: 'Club Speed',
                              value: '${shot['clubSpeed']} mph',
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              label: 'Ball Speed',
                              value: '${shot['ballSpeed']} mph',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              label: 'Carry',
                              value: '${shot['carryDistance']} yds',
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              label: 'Total',
                              value: '${shot['totalDistance']} yds',
                              valueColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${shot['date']} at ${shot['time']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (shot['sessionTime'] != null)
                            Text(
                              'Session: ${shot['sessionTime']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return _buildScanScreen(context, state);
        }
      },
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
            const Divider(thickness: 1, color: AppColors.dividerColor),
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

  Widget _buildConnectedScreen(BuildContext context, ConnectedState state) {
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
          Divider(thickness: 1, color: AppColors.dividerColor),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
              child: Column(
                children: [
                  HeaderRow(
                    showClubName: true,
                    goScanScreen: true,
                    headingName: "Shot Analysis",
                    selectedClub: Club(
                      code: state.golfData.clubName.toString(),
                      name: _clubs[state.golfData.clubName],
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
                  CustomizeBar(),
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
                          child: GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 30,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1.42,
                            ),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              final metrics = [
                                {
                                  "metric": "Club Speed",
                                  "value": state.golfData.clubSpeed
                                      .toStringAsFixed(1),
                                  "unit": "MPH"
                                },
                                {
                                  "metric": "Ball Speed",
                                  "value": state.golfData.ballSpeed
                                      .toStringAsFixed(1),
                                  "unit": "MPH"
                                },
                                {
                                  "metric": "Carry Distance",
                                  "value": state.golfData.carryDistance
                                      .toStringAsFixed(1),
                                  "unit": state.units ? "M" : "YDS"
                                },
                                {
                                  "metric": "Total Distance",
                                  "value": state.golfData.totalDistance
                                      .toStringAsFixed(1),
                                  "unit": state.units ? "M" : "YDS"
                                },
                                {
                                  "metric": "Smash Factor",
                                  "value": state.golfData.smashFactor
                                      .toStringAsFixed(2),
                                  "unit": ""
                                },
                              ];
                              return GlassmorphismCard(
                                value: metrics[index]["value"]!,
                                name: metrics[index]["metric"]!,
                                unit: metrics[index]["unit"]!,
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ActionButton(
                          text: AppStrings.deleteShotText,
                          onPressed: () {},
                        ),
                        ActionButton(
                          svgAssetPath: AppImages.groupIcon,
                          text: AppStrings.dispersionText,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
                  SessionViewButton(
                    onSessionClick: () async {
                      context.read<GolfDeviceBloc>().add(SaveAllShotsEvent());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
