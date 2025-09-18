import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Slurvo/core/constants/app_strings.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_bloc.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_event.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_state.dart';
import 'package:Slurvo/feature/home_screens/presentation/pages/shot_analysis_page.dart';

class ScannedDevicesScreen extends StatelessWidget {
  const ScannedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Scanned Devices",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<BleBloc, BleState>(
        listener: (context, state) {
          if (state is BleConnected) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ShotAnalysisPage(),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BleScanning) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is BleScannedDevices) {
            final List<BleDevice> devices = state.scannedDevice;

            if (devices.isEmpty) {
              return const Center(
                child: Text(
                  AppStrings.noDataShowing,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(
                    device.name.isNotEmpty ? device.name : AppStrings.unknown,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "ID: ${device.id} | RSSI: ${device.rssi}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    context.read<BleBloc>().add(
                          ConnectToDeviceEvent(device.id),
                        );
                  },
                );
              },
            );
          }

          return const Center(
            child: Text(
              "Scanning for devices...",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
