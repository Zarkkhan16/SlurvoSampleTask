import 'package:Slurvo/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Slurvo/core/constants/app_strings.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_bloc.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_event.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_state.dart';
import 'package:Slurvo/feature/home_screens/presentation/pages/shot_analysis_page.dart';

class ScannedDevicesScreen extends StatefulWidget {
  const ScannedDevicesScreen({super.key});

  @override
  State<ScannedDevicesScreen> createState() => _ScannedDevicesScreenState();
}

class _ScannedDevicesScreenState extends State<ScannedDevicesScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Scanned Devices",
          style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => context.read<BleBloc>().add(StartScanEvent()),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: BlocConsumer<BleBloc, BleState>(
        listener: (context, state) {
          if (state is BleConnected && !_isNavigating) {
            _isNavigating = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<BleBloc>(), // pass the same instance
                  child: const ShotAnalysisPage(),
                ),
              ),
            ).then((_) => _isNavigating = false);

          }
          if (state is BlePairingRequested) {
            _showPairingDialog(context, state.deviceId, state.deviceName);
          }
          if (state is BleError&&state is! BleConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => context.read<BleBloc>().add(StartScanEvent()),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BleScanning || state is BleConnecting) {
            final message = state is BleConnecting
                ? "Connecting to ${state.deviceName ?? 'device'}..."
                : "Scanning for devices...";
            return _centerMessage(context, w, message, showLoader: true);
          }

          if (state is BleError&&state is! BleConnected) {
            return _centerMessage(context, w, state.message, showRetry: true);
          }

          if (state is BleScannedDevices&&state is! BleConnected) {
            final devices = state.scannedDevice;
            if (devices.isEmpty) {
              return _centerMessage(context, w, "No devices found", showRetry: true);
            }
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(w * 0.04),
                  child: Text(
                    "Found ${devices.length} device${devices.length == 1 ? '' : 's'}",
                    style: TextStyle(color: Colors.white70, fontSize: w * 0.035),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.01),
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: Icon(Icons.bluetooth, color: _getSignalColor(device.rssi), size: w * 0.06),
                          title: Text(
                            device.name.isNotEmpty ? device.name : AppStrings.unknown,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text("ID: ${device.id}\nSignal: ${device.rssi} dBm ${_getSignalStrength(device.rssi)}",
                              style: TextStyle(color: Colors.white70)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_shouldShowPairButton(device))
                                IconButton(
                                  onPressed: () => context
                                      .read<BleBloc>()
                                      .add(RequestPairingEvent(device.id, device.name)),
                                  icon: Icon(Icons.bluetooth_connected, color: Colors.blue, size: w * 0.05),
                                ),
                              Icon(Icons.arrow_forward_ios, color: Colors.white54, size: w * 0.04),
                            ],
                          ),
                          onTap: () => context
                              .read<BleBloc>()
                              .add(ConnectToDeviceEvent(device.id, deviceName: device.name)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return SizedBox();
        },
      ),
    );
  }

  Widget _centerMessage(BuildContext context, double w, String message,
      {bool showLoader = false, bool showRetry = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLoader) const CircularProgressIndicator(color: Colors.white),
          SizedBox(height: w * 0.04),
          Text(message, style: TextStyle(color: Colors.white, fontSize: w * 0.045), textAlign: TextAlign.center),
          if (showRetry)
            Padding(
              padding: EdgeInsets.only(top: w * 0.04),
              child: ElevatedButton(
                onPressed: () => context.read<BleBloc>().add(StartScanEvent()),
                child: const Text("Retry Scan"),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSignalColor(int rssi) => rssi >= -50
      ? Colors.green
      : rssi >= -70
      ? Colors.orange
      : Colors.red;

  String _getSignalStrength(int rssi) =>
      rssi >= -50 ? "(Excellent)" : rssi >= -70 ? "(Good)" : "(Weak)";

  bool _shouldShowPairButton(BleDevice device) {
    final name = device.name.toLowerCase();
    return [
      'headphone', 'speaker', 'keyboard', 'mouse', 'watch', 'fitness',
      'band', 'tracker', 'earbuds', 'airpods', 'beats', 'sony', 'bose',
      'mi ', 'xiaomi'
    ].any(name.contains) || device.rssi > -60;
  }

  void _showPairingDialog(BuildContext context, String deviceId, String deviceName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(children: [
          const Icon(Icons.bluetooth_connected, color: Colors.blue),
          const SizedBox(width: 10),
          Text('Pair Device', style: const TextStyle(color: Colors.white)),
        ]),
        content: Text('Do you want to pair with "$deviceName"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Future.delayed(const Duration(seconds: 2), () {
                  context.read<BleBloc>().add(ConnectToDeviceEvent(deviceId, deviceName: deviceName));
                });
              },
              child: const Text('Pair'))
        ],
      ),
    );
  }
}
