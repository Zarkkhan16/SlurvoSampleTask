import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/bottom_controller.dart';
import 'package:onegolf/feature/profile/presentation/pages/profile_screen.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';
import '../../../../core/services/ble_connection_helper.dart';
import '../../../ble_management/presentation/bloc/ble_management_bloc.dart';
import '../../../ble_management/presentation/bloc/ble_management_state.dart';
import '../../../ble_management/presentation/presentation/device_connected_screen.dart';
import '../../../golf_device/presentation/bloc/golf_device_bloc.dart';
import '../../../golf_device/presentation/bloc/golf_device_event.dart';
import '../../../golf_device/presentation/pages/golf_device_screen.dart';
import '../../../setting/persentation/pages/setting_screen.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/gradient_border_container.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widget/game_mode_icon.dart';

class LandingDashboard extends StatefulWidget {
  const LandingDashboard({super.key});

  @override
  State<LandingDashboard> createState() => _LandingDashboardState();
}

class _LandingDashboardState extends State<LandingDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadUserProfile());
  }

  double w(BuildContext context, double size) =>
      MediaQuery.of(context).size.width * (size / 375);

  double h(BuildContext context, double size) =>
      MediaQuery.of(context).size.height * (size / 812);

  Future<void> _navigateWithBleCheck({
    required BuildContext context,
    required Widget destination,
    required String screenName,
    int? targetTabIndex,
  }) async {
    final isConnected =
        await BleConnectionHelper.ensureDeviceConnected(context);

    if (isConnected && mounted) {
      final bloc = context.read<GolfDeviceBloc>();

      // 🔥 THIS WAS MISSING
      bloc.add(
        ConnectionStateChangedEvent(
          bloc.bleRepository.isConnected,
        ),
      );
      // BottomNavController.currentIndex.value = 1;
      if (targetTabIndex != null &&
          BottomNavController.currentIndex.value != targetTabIndex) {
        BottomNavController.currentIndex.value = targetTabIndex;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: screenName),
          builder: (context) => destination,
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Device connection required',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: AppTextStyle.roboto(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(
                            RefreshDashboard(),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: w(context, 12), vertical: h(context, 12)),
                  width: double.infinity,
                  height: h(context, 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(w(context, 16)),
                  ),
                  child: GradientBorderContainer(
                    borderRadius: w(context, 16),
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(w(context, 16)),
                      child: Image.asset(
                        'assets/png/test.jpeg',
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                // Shot Analysis Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w(context, 12)),
                  child: GestureDetector(
                    onTap: () {
                      _navigateWithBleCheck(
                        context: context,
                        screenName: "GolfDeviceView",
                        destination: BlocProvider.value(
                          value: context.read<GolfDeviceBloc>(),
                          child: GolfDeviceView(),
                        ),
                        targetTabIndex: 1,
                      );
                    },
                    child: GradientBorderContainer(
                      borderRadius: w(context, 32),
                      borderWidth: 1,
                      containerHeight: h(context, 130),
                      padding: EdgeInsets.symmetric(
                        horizontal: w(context, 20),
                        vertical: h(context, 15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w(context, 16),
                                    vertical: h(context, 5),
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.white, Colors.white38],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(w(context, 4)),
                                  ),
                                  child: Text(
                                    "  Free  ",
                                    style: AppTextStyle.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                ),
                                SizedBox(height: h(context, 3)),
                                Text(
                                  "Shot Analysis",
                                  softWrap: true,
                                  maxLines: 2,
                                  style: AppTextStyle.roboto(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  "Track your shots in real-time with accurate ball and club metrics.",
                                  softWrap: true,
                                  maxLines: 3,
                                  style: AppTextStyle.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: w(context, 16)),
                          Transform.scale(
                            scale: MediaQuery.of(context).size.width < 360
                                ? 1.6
                                : 2.0,
                            child: Image.asset(
                              AppImages.deviceImage,
                              width: w(context, 100),
                              height: h(context, 140),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     _navigateWithBleCheck(
                  //       context: context,
                  //       screenName: "GolfDeviceView",
                  //       destination: BlocProvider.value(
                  //         value: context.read<GolfDeviceBloc>(),
                  //         child: GolfDeviceView(),
                  //       ),
                  //     );
                  //   },
                  //   child: GradientBorderContainer(
                  //     borderRadius: 32,
                  //     borderWidth: 1,
                  //     containerHeight: 130,
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 20, vertical: 6),
                  //     child: Row(
                  //       children: [
                  //         Expanded(
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Container(
                  //                 padding: const EdgeInsets.symmetric(
                  //                     horizontal: 10, vertical: 5),
                  //                 decoration: BoxDecoration(
                  //                   gradient: const LinearGradient(
                  //                     colors: [
                  //                       Colors.white,
                  //                       Colors.white54,
                  //                     ],
                  //                     begin: Alignment.topLeft,
                  //                     end: Alignment.bottomRight,
                  //                   ),
                  //                   borderRadius: BorderRadius.circular(4),
                  //                 ),
                  //                 child: Text(
                  //                   "Free",
                  //                   style: AppTextStyle.roboto(
                  //                       fontSize: 14,
                  //                       fontWeight: FontWeight.w400,
                  //                       color: Colors.black),
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 3),
                  //               Text(
                  //                 "Shot Analysis",
                  //                 style: AppTextStyle.roboto(
                  //                   fontSize: 22,
                  //                   fontWeight: FontWeight.w900,
                  //                   color: Colors.white,
                  //                   height: 1.3,
                  //                 ),
                  //               ),
                  //               // const SizedBox(height: 5),
                  //               Text(
                  //                 "Track your shots in real-time with accurate ball and club metrics.",
                  //                 style: AppTextStyle.roboto(
                  //                     fontSize: 16,
                  //                     fontWeight: FontWeight.w400,
                  //                     color: Colors.white,
                  //                     height: 1.0),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(width: 16),
                  //         Transform.scale(
                  //           scale: 2.0,
                  //           child: Image.asset(
                  //             AppImages.deviceImage,
                  //             width: 100,
                  //             height: 140,
                  //             fit: BoxFit.cover,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ),
                SizedBox(height: h(context, 10)),
                // Practice Games Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      BottomNavController.goToTab(2);

                      // NEW: Check BLE connection before navigating
                      // _navigateWithBleCheck(
                      //   context: context,
                      //   screenName: "PracticeGamesScreen",
                      //   destination: BlocProvider.value(
                      //     value: context.read<PracticeGamesBloc>(),
                      //     child: PracticeGamesScreen(),
                      //   ),
                      // );
                    },
                    child: GradientBorderContainer(
                      containerHeight: h(context, 130),
                      borderRadius: w(context, 32),
                      padding: EdgeInsets.symmetric(
                        horizontal: w(context, 20),
                        vertical: h(context, 15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w(context, 10),
                                    vertical: h(context, 5),
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xffFCD56A),
                                        Color(0xffFCD56A),
                                        Color(0xffB6782A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(w(context, 4)),
                                  ),
                                  child: Text(
                                    "Premium",
                                    style: AppTextStyle.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Practice Games",
                                  softWrap: true,
                                  maxLines: 2,
                                  style: AppTextStyle.roboto(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  "Improve your skills with engaging and competitive practice modes.",
                                  softWrap: true,
                                  maxLines: 3,
                                  style: AppTextStyle.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GameModeIcon(
                                      icon: AppImages.combineTestIcon,
                                      label: "Combine Test",
                                    ),
                                    GameModeIcon(
                                      icon: AppImages.ladderDrillIcon,
                                      label: "Ladder Drill",
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GameModeIcon(
                                      icon: AppImages.longestDriveIcon,
                                      label: "Longest Drive",
                                    ),
                                    GameModeIcon(
                                      icon: AppImages.clubGappingIcon,
                                      label: "Club Gapping",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h(context, 10)),
                // Shot Library
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      BottomNavController.goToTab(3);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => BlocProvider.value(
                      //       value: context.read<ShotLibraryBloc>(),
                      //       child: const ShotLibraryHomePage(),
                      //     ),
                      //   ),
                      // );
                    },
                    child: GradientBorderContainer(
                      containerHeight: h(context, 130),
                      borderRadius: w(context, 32),
                      padding: EdgeInsets.symmetric(
                        horizontal: w(context, 20),
                        vertical: h(context, 15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w(context, 10),
                                    vertical: h(context, 5),
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xffFCD56A),
                                        Color(0xffFCD56A),
                                        Color(0xffB6782A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(w(context, 4)),
                                  ),
                                  child: Text(
                                    "Premium",
                                    style: AppTextStyle.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Shot Library",
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                  style: AppTextStyle.roboto(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  "Improve your skills with engaging and competitive practice modes.",
                                  softWrap: true,
                                  maxLines: 3,
                                  overflow: TextOverflow.visible,
                                  style: AppTextStyle.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          SvgPicture.asset(
                            AppImages.libraryIcon,
                            width: w(context, 75),
                            height: h(context, 60),
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h(context, 10)),
                // Setting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      _navigateWithBleCheck(
                        context: context,
                        destination: const SettingScreen(
                          selectedUnit: true,
                        ),
                        screenName: 'SettingScreen',
                      );

                    },
                    child: GradientBorderContainer(
                      containerHeight: h(context, 130),
                      borderRadius: w(context, 32),
                      padding: EdgeInsets.symmetric(
                        horizontal: w(context, 20),
                        vertical: h(context, 6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: h(context, 20)),
                                Text(
                                  "Setting",
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                  style: AppTextStyle.roboto(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  "Manage your profile, subscriptions, and device connections.",
                                  softWrap: true,
                                  maxLines: 3,
                                  overflow: TextOverflow.visible,
                                  style: AppTextStyle.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          SvgPicture.asset(
                            AppImages.settingsIcon,
                            width: w(context, 75),
                            height: h(context, 60),
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                BlocBuilder<BleManagementBloc, BleManagementState>(
                  builder: (context, bleState) {
                    final isConnected = bleState is BleConnectedState;
                    final isConnecting = bleState is BleConnectingState;
                    final isScanning = bleState is BleScanningState;
                    String buttonText;

                    if (isScanning) {
                      buttonText = "Scanning for Devices...";
                    } else if (isConnecting) {
                      buttonText = "Connecting...";
                    } else if (isConnected) {
                      buttonText = "Bluetooth Connected";
                    } else {
                      buttonText = "Connect Bluetooth";
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: w(context, 12)),
                      child: SessionViewButton(
                        onSessionClick: (isScanning || isConnecting)
                            ? null
                            : () =>
                                _handleBluetoothButtonTap(context, isConnected),
                        iconSvg: AppImages.bluetoothIcon,
                        buttonText: buttonText,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleBluetoothButtonTap(
      BuildContext context, bool isConnected) async {
    if (isConnected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<BleManagementBloc>(),
            child: DeviceConnectedScreen(),
          ),
        ),
      );
    } else {
      final connected =
          await BleConnectionHelper.ensureDeviceConnected(context);

      if (connected && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Device connected successfully!',
              style: AppTextStyle.roboto(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
