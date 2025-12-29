import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../widget/custom_app_bar.dart';
import '../bloc/ble_management_bloc.dart';
import '../bloc/ble_management_event.dart';
import '../bloc/ble_management_state.dart';

class BleConnectionDialog extends StatelessWidget {
  final VoidCallback? onConnected;
  final VoidCallback? onCancelled;

  const BleConnectionDialog({
    super.key,
    this.onConnected,
    this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    context.read<BleManagementBloc>().add(StartScanEvent());

    return BlocConsumer<BleManagementBloc, BleManagementState>(
      listener: (context, state) {
        if (state is BleConnectedState) {
          Navigator.of(context).pop(true);
          onConnected?.call();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: CustomAppBar(),
          // bottomNavigationBar: BottomNavBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
            child: Column(
              children: [
                HeaderRow(
                  headingName: 'Connect Your Device',
                  onBackButton: () {
                    context.read<BleManagementBloc>().add(StopScanEvent());
                    Navigator.of(context).pop(false);
                    onCancelled?.call();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("•  ", style: TextStyle(fontSize: 18, height: 1.2)),
                          Expanded(
                            child: Text(
                              "Turn on your compatible launch monitor or swing sensor",
                              style: AppTextStyle.roboto(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("•  ", style: TextStyle(fontSize: 18, height: 1.2)),
                          Expanded(
                            child: Text(
                              "Keep Bluetooth enabled on your phone",
                              style: AppTextStyle.roboto(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                if (state is BleScanningState) ...[
                  _buildScanningView(context, state),
                ] else if (state is BleDevicesFoundState) ...[
                  _buildDevicesListView(context, state),
                ] else if (state is BleConnectingState) ...[
                  _buildConnectingView(context, state),
                ] else if (state is BleConnectionFailedState) ...[
                  _buildErrorView(context, state.message),
                ] else if (state is BleErrorState) ...[
                  _buildErrorView(context, state.message),
                ] else ...[
                  _buildInitialView(context),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanningView(BuildContext context, BleScanningState state) {
    return Column(
      children: [
        const CircularProgressIndicator(
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        Text(
          "Scanning for devices...",
          style: AppTextStyle.roboto(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        if (state.devices.isNotEmpty) ...[
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                final device = state.devices[index];
                return _buildDeviceTile(context, device);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDevicesListView(
      BuildContext context, BleDevicesFoundState state) {
    if (state.devices.isEmpty) {
      return Column(
        children: [
          const Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            "No devices found",
            style: AppTextStyle.roboto(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<BleManagementBloc>().add(StartScanEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Scan Again",
              style: AppTextStyle.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          "Nearby Devices",
          style: AppTextStyle.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView.builder(
            itemCount: state.devices.length,
            itemBuilder: (context, index) {
              final device = state.devices[index];
              return _buildDeviceTile(context, device);
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.read<BleManagementBloc>().add(StartScanEvent());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            "Scan Again",
            style: AppTextStyle.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceTile(BuildContext context, device) {
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.bluetooth, color: Colors.white),
        title: Text(
          device.name,
          style: AppTextStyle.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "RSSI: ${device.rssi}",
          style: AppTextStyle.roboto(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            context.read<BleManagementBloc>().add(
                  ConnectToDeviceEvent(
                    deviceId: device.id,
                    deviceName: device.name,
                  ),
                );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          child: const Text("Connect"),
        ),
      ),
    );
  }

  Widget _buildConnectingView(BuildContext context, BleConnectingState state) {
    return Column(
      children: [
        const CircularProgressIndicator(
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        Text(
          "Connecting to ${state.deviceName}...",
          style: AppTextStyle.roboto(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: AppTextStyle.roboto(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            context.read<BleManagementBloc>().add(StartScanEvent());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            "Try Again",
            style: AppTextStyle.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        Text(
          "Initializing...",
          style: AppTextStyle.roboto(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
