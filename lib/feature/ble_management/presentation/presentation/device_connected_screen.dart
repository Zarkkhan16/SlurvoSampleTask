import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:onegolf/core/constants/app_images.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/gradient_border_container.dart';
import '../bloc/ble_management_event.dart';
import '../bloc/ble_management_state.dart';
import 'device_guide_screen.dart';
import '../../../ble_management/presentation/bloc/ble_management_bloc.dart';

class DeviceConnectedScreen extends StatelessWidget {
  const DeviceConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleManagementBloc, BleManagementState>(
      listener: (context, state) {
        if (state is BleDisconnectedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Device disconnected', style: AppTextStyle.roboto(),),
              backgroundColor: Colors.redAccent,
            ),
          );
          Navigator.pop(context);
        } else if (state is BleErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isConnected = state is BleConnectedState;
        final isDisconnecting = state is BleDisconnectedState;
        final deviceName =
            state is BleConnectedState ? state.deviceName : 'Unknown';

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: CustomAppBar(),
          bottomNavigationBar: BottomNavBar(),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                HeaderRow(
                  headingName: "Connect Status",
                ),
                SizedBox(height: 20),
                GradientBorderContainer(
                  borderRadius: 16,
                  borderWidth: 1,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 25),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppImages.connectedIcon,
                        height: 50,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isConnected ? "Connected" : "Disconnected",
                              style: AppTextStyle.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              isConnected
                                  ? "Ready to Track Shots"
                                  : "Device not connected",
                              style: AppTextStyle.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isConnected) ...[
                              SizedBox(height: 5),
                              Text(
                                deviceName,
                                style: AppTextStyle.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? "Connected" : "Connection Tips",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildItem("Is your device powered on?", isConnected),
                      _buildItem("Is Bluetooth enable?", isConnected),
                      _buildItem("Is the device in range?", isConnected),
                      _buildItem(
                        "Try restarting your phone or device",
                        false,
                        isLoading: !isConnected,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "View Supported Devices",
                          style: AppTextStyle.roboto(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: "Need help connecting? ",
                          style: AppTextStyle.roboto(),
                          children: [
                            TextSpan(
                              text: "Step-by-step guide",
                              style: AppTextStyle.roboto(
                                fontWeight: FontWeight.w700,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DeviceGuideScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SessionViewButton(
                  onSessionClick: isDisconnecting
                      ? null
                      : () {
                          if (isConnected) {
                            _showDisconnectConfirmation(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                  buttonText: isDisconnecting
                      ? "Disconnecting..."
                      : (isConnected
                          ? "Disconnect Device"
                          : "Reconnect Device"),
                ),
                SizedBox(height: 20),
                Text(
                  "Still having issue?",
                  style: AppTextStyle.roboto(fontSize: 16),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact Support feature coming soon'),
                      ),
                    );
                  },
                  child: Text(
                    "Contact Support",
                    style: AppTextStyle.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDisconnectConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Color(0xFF1C1C1E),
        title: Text(
          'Disconnect Device?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to disconnect the device?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BleManagementBloc>().add(DisconnectEvent());
            },
            child: Text(
              'Disconnect',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String text, bool isChecked, {bool isLoading = false}) {
    IconData icon;
    Color iconColor;

    if (isLoading) {
      icon = Icons.refresh;
      iconColor = Colors.orange;
    } else if (isChecked) {
      icon = Icons.check;
      iconColor = Colors.green;
    } else {
      icon = Icons.refresh;
      iconColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
