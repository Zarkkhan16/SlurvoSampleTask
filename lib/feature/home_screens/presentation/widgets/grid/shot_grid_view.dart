import 'package:Slurvo/core/di/injection_container.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_characteristic.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:Slurvo/core/constants/app_constants.dart';
import 'package:Slurvo/core/constants/app_strings.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_bloc.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_event.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_state.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/card/glassmorphism_card.dart';
import 'package:Slurvo/feature/home_screens/domain/entities/shot_data.dart';

import '../../../domain/entities/shot_parser.dart';

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
        print('????????{{{');
        print(state);
        if (state is BleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        // if (state is BleScannedDevices) {
        //   final matchingDevices = state.scannedDevice
        //       .where((device) => device.id.toUpperCase() == AppConstants.bleId);
        //
        //   if (matchingDevices.isEmpty && !_deviceWithUUIDFound) {
        //     _deviceWithUUIDFound = true;
        //     Fluttertoast.showToast(
        //       msg: AppStrings.deviceNotFound,
        //       toastLength: Toast.LENGTH_LONG,
        //       gravity: ToastGravity.BOTTOM,
        //       backgroundColor: Colors.black87,
        //       textColor: Colors.white,
        //     );
        //     context.read<BleBloc>().add(ShowMockDataEvent());
        //   }
        // }
      },
      builder: (context, state) {
        print(state);
        // if ((state is BleInitial || state is BleDisconnected) && !_scanStarted) {
        //   context.read<BleBloc>().add(StartScanEvent());
        //   _scanStarted = true;
        // }
        //
        // if (state is BleScanning || state is BleInitial || state is BleDisconnected) {
        //   return const Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         CircularProgressIndicator(color: AppColors.primaryText),
        //         SizedBox(height: 16),
        //         Text(AppStrings.scanning, style: TextStyle(color: Colors.white)),
        //       ],
        //     ),
        //   );
        // }

        // if (state is BleConnected) {
        //   final services = state.services;
        //
        //   return _buildDeviceGrid(services, context);
        //   // return Center(
        //   //   child: GlassmorphismCard(
        //   //     value: "Connected",
        //   //     name: device.name.isNotEmpty ? device.name : AppStrings.unknown,
        //   //     unit: device.id,
        //   //   ),
        //   // );
        // }

        if (state is BleConnected) {
          // Just show message that device is connected
          return const Center(
            child: Text("✅ Device Connected. Waiting for data...",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          );
        }

        if (state is BleShotData) {
          return _buildShotGrid(state.shots);
        }

        // if (state is BleScannedDevices) {
        //
        //   final devices = state.scannedDevice;
        //
        //   if (devices.isEmpty) {
        //     context.read<BleBloc>().add(ShowMockDataEvent());
        //     return const Center(
        //       child: Text(AppStrings.noDataShowing),
        //     );
        //   } else {
        //     return _buildDeviceGrid(devices, context);
        //   }
        // }

        if (state is BleMockDataFound) {
          final List<ShotData> mockData = state.mockData;
          return _buildMockDataGrid(mockData);
        }

        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryText),
        );
      },
    );
  }

  // Widget _buildDeviceGrid(List<BleService> services, BuildContext context) {
  //   // Filter services containing FFE0
  //   final targetServices =
  //       services.where((s) => s.uuid.toUpperCase().contains("FFE0")).toList();
  //
  //   // If no service found, show message
  //   if (targetServices.isEmpty) {
  //     return Center(
  //       child: Text(
  //         "No service with ID FFE0 found",
  //         style: const TextStyle(color: Colors.white, fontSize: 16),
  //         textAlign: TextAlign.center,
  //       ),
  //     );
  //   }
  //
  //   return GridView.builder(
  //     padding: const EdgeInsets.all(16),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 30,
  //       mainAxisSpacing: 20,
  //       childAspectRatio: 1.42,
  //     ),
  //     itemCount: targetServices.length,
  //     itemBuilder: (context, index) {
  //       final service = targetServices[index];
  //
  //       // characteristic containing FEE2
  //       BleCharacteristic? targetCharacteristic;
  //       if (service.characteristics.isNotEmpty) {
  //         final index = service.characteristics.indexWhere(
  //           (c) => c.uuid.toUpperCase().contains("FEE2"),
  //         );
  //         if (index != -1) {
  //           targetCharacteristic = service.characteristics[index];
  //         }
  //       }
  //
  //       if (targetCharacteristic == null) {
  //         return GlassmorphismCard(
  //           value: "--",
  //           name: "No FEE2 in ${service.uuid}",
  //           unit: "",
  //         );
  //       }
  //
  //       // Extract value safely
  //       String value = targetCharacteristic.value != null
  //           ? targetCharacteristic.value.toString()
  //           : "--";
  //       String name = targetCharacteristic.uuid;
  //       List<ShotDataNew> parsedData = [];
  //       if (targetCharacteristic.value != null &&
  //           targetCharacteristic.value!.isNotEmpty) {
  //         parsedData = ShotParser.parse(targetCharacteristic.value!);
  //       } else {
  //         // Use example data for demonstration
  //         parsedData = ShotParser.parseExampleData();
  //       }
  //
  //       print('Device Data Chara');
  //       print(parsedData);
  //       return GestureDetector(
  //         onTap: () {
  //           // ScaffoldMessenger.of(context).showSnackBar(
  //           //   const SnackBar(content: Text(AppStrings.connecting)),
  //           // );
  //           // context.read<BleBloc>().add(ConnectToDeviceEvent(service.uuid));
  //         },
  //         child: GlassmorphismCard(
  //           value: value,
  //           name: name,
  //           unit: name,
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildDeviceGrid(List<BleService> services, BuildContext context) {
  //   // Filter services containing FFE0
  //   final targetServices =
  //   services.where((s) => s.uuid.toUpperCase().contains("FFE0")).toList();
  //
  //   if (targetServices.isEmpty) {
  //     return const Center(
  //       child: Text(
  //         "No service with ID FFE0 found",
  //         style: TextStyle(color: Colors.white, fontSize: 16),
  //         textAlign: TextAlign.center,
  //       ),
  //     );
  //   }
  //
  //   // ⚡ Instead of looping services → just take the first FFE0
  //   final service = targetServices.first;
  //
  //   print('Services');
  //   print(service);
  //
  //   // Find FEE2 characteristic
  //   final targetCharacteristic = service.characteristics.firstWhere(
  //         (c) => c.uuid.toUpperCase().contains("FEE2"),
  //   );
  //
  //   print('Target Characteristic');
  //   print(targetCharacteristic.value);
  //   // Parse values
  //   List<ShotDataNew> parsedData = [];
  //   if (targetCharacteristic.value != null &&
  //       targetCharacteristic.value!.isNotEmpty) {
  //     parsedData = ShotParser.parse(targetCharacteristic.value!);
  //     print('Parsed Data');
  //     print(parsedData);
  //   }
  //   //   else {
  //   //   parsedData = ShotParser.parseExampleData();
  //   // }
  //
  //   // 🔥 Now build cards from parsedData
  //   return GridView.builder(
  //     padding: const EdgeInsets.all(16),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 30,
  //       mainAxisSpacing: 20,
  //       childAspectRatio: 1.42,
  //     ),
  //     itemCount: parsedData.length,
  //     itemBuilder: (context, index) {
  //       final shot = parsedData[index];
  //       return GlassmorphismCard(
  //         value: "${shot.value}",
  //         name: shot.metric,
  //         unit: shot.unit,
  //       );
  //     },
  //   );
  // }

  Widget _buildShotGrid(List<ShotDataNew> shots) {
    if (shots.isEmpty) {
      return const Center(
        child: Text(
          "No shot data received yet",
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 20,
        childAspectRatio: 1.42,
      ),
      itemCount: shots.length,
      itemBuilder: (context, index) {
        final shot = shots[index];
        return GlassmorphismCard(
          value: "${shot.value}",
          name: shot.metric,
          unit: shot.unit,
        );
      },
    );
  }

  Widget _buildMockDataGrid(List<ShotData> mockData) {
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
