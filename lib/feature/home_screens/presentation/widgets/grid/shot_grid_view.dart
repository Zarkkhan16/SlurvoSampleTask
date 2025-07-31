import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sample_task/core/constants/app_colors.dart';
import 'package:sample_task/core/constants/app_constants.dart';
import 'package:sample_task/core/constants/app_strings.dart';
import 'package:sample_task/feature/ble/presentation/block/ble_bloc.dart';
import 'package:sample_task/feature/ble/presentation/block/ble_event.dart';
import 'package:sample_task/feature/ble/presentation/block/ble_state.dart';
import 'package:sample_task/feature/home_screens/presentation/widgets/card/glassmorphism_card.dart';

class ShotGridView extends StatefulWidget {
  const ShotGridView({super.key});

  @override
  State<ShotGridView> createState() => _ShotGridViewState();
}

class _ShotGridViewState extends State<ShotGridView> {
  bool _scanStarted = false;
  bool _deviceWithUUIDFound = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {
        if (state is BleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is BleDevicesFound) {
          var targetDevice;

          if(state.devices.isNotEmpty)
            {
               targetDevice = state.devices.firstWhere(
                    (device) => device.id.toUpperCase() ==AppConstants.bleId ,
              );
            }


          if (targetDevice == null && !_deviceWithUUIDFound) {
            _deviceWithUUIDFound = true;
            Fluttertoast.showToast(
              msg: AppStrings.deviceNotFound,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
            );
            context.read<BleBloc>().add(ShowMockDataEvent());
          }
        }
      },
      builder: (context, state) {
        if ((state is BleInitial || state is BleDisconnected) && !_scanStarted) {
          context.read<BleBloc>().add(StartScanEvent());
          _scanStarted = true;
        }

        if (state is BleScanning || state is BleInitial || state is BleDisconnected) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryText),
                SizedBox(height: 16),
                Text(AppStrings.scanning, style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        if (state is BleDevicesFound) {
          final devices = state.devices;

          if (devices.isEmpty) {
            context.read<BleBloc>().add(ShowMockDataEvent());
            return const Center(
              child: Text(AppStrings.noDataShowing),
            );
          } else {
            return _buildDeviceGrid(devices, context);
          }
        }

        if (state is BleMockDataFound) {
          final mockData = state.mockData;
          return _buildMockDataGrid(mockData);
        }

        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryText),
        );
      },
    );
  }

  Widget _buildDeviceGrid(List devices, BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 20,
        childAspectRatio: 1.42,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.connecting)),
            );
            context.read<BleBloc>().add(ConnectToDeviceEvent(device.id));
          },
          child: GlassmorphismCard(
            value: "${device.rssi}",
            name: device.name.isNotEmpty ? device.name : AppStrings.unknown,
            unit: device.type,
          ),
        );
      },
    );
  }

  Widget _buildMockDataGrid(List mockData) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 20,
        childAspectRatio: 1.42,
      ),
      itemCount: mockData.length,
      itemBuilder: (context, index) {
        final shot = mockData[index];
        return GlassmorphismCard(
          value: "${shot.value}",
          name: shot.metric,
          unit: shot.unit,
        );
      },
    );
  }
}
