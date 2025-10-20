// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:onegolf/demoapp.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../golf_device/domain/entities/device_entity.dart';
// import '../../../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
// import '../../../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
// import '../../../home_screens/presentation/widgets/header/header_row.dart';
//
// class SettingScreen extends StatefulWidget {
//   final DeviceEntity? connectedDevice;
//   final List<DiscoveredService> services;
//   final bool selectedUnit;
//
//   SettingScreen({super.key, required this.connectedDevice, required this.services,required this.selectedUnit});
//
//   @override
//   State<SettingScreen> createState() => _SettingScreenState();
// }
//
// class _SettingScreenState extends State<SettingScreen> {
//   bool backlight = false;
//   int sleepTime = 5;
//   bool selectedUnit = false;
//
//   final FlutterReactiveBle _ble = FlutterReactiveBle();
//   Uuid? _serviceId;
//   Uuid? _writeCharId;
//   bool? _useWriteWithResponse;
//   bool _isWriting = false;
//   bool isSendingRequest = false;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedUnit=widget.selectedUnit;
//     _loadPrefs();
//     _findCharacteristics();
//   }
//
//   Future<void> _loadPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       backlight = prefs.getBool("backlight") ?? false;
//       sleepTime = prefs.getInt("sleepTime") ?? 5;
//     });
//   }
//
//   Future<void> _savePrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool("backlight", backlight);
//     await prefs.setInt("sleepTime", sleepTime);
//     // Save as boolean for consistency
//     await prefs.setBool("unit", selectedUnit);
//   }
//
//   void _findCharacteristics() {
//     for (var service in widget.services) {
//       if (service.serviceId.toString().toLowerCase().contains("ffe0")) {
//         _serviceId = service.serviceId;
//         for (var c in service.characteristics) {
//           String charId = c.characteristicId.toString().toLowerCase();
//           if (charId.contains("fee1") && (c.isWritableWithResponse || c.isWritableWithoutResponse)) {
//             _writeCharId = c.characteristicId;
//             _useWriteWithResponse = c.isWritableWithResponse;
//             break;
//           }
//         }
//         break;
//       }
//     }
//   }
//
//   Future<void> _sendCommand(int cmd, int param1, int param2) async {
//     if (_isWriting || widget.connectedDevice == null || _serviceId == null || _writeCharId == null) return;
//
//     _isWriting = true;
//
//     List<int> packet = [0x47, 0x46, cmd, param1, param2];
//     int checksum = packet.skip(2).fold(0, (sum, byte) => sum + byte) & 0xFF;
//     packet.add(checksum);
//
//     try {
//       final char = QualifiedCharacteristic(
//         serviceId: _serviceId!,
//         characteristicId: _writeCharId!,
//         deviceId: widget.connectedDevice!.id,
//       );
//
//       if (_useWriteWithResponse == true) {
//         await _ble.writeCharacteristicWithResponse(char, value: packet);
//       } else {
//         await _ble.writeCharacteristicWithoutResponse(char, value: packet);
//       }
//
//     } catch (e) {
//       print('Write error: $e');
//     }
//
//     await Future.delayed(Duration(milliseconds: 500));
//     _isWriting = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryBackground,
//       bottomNavigationBar: const BottomNavBar(),
//       appBar: const CustomAppBar(),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             const Divider(thickness: 1, color: AppColors.dividerColor),
//             SizedBox(
//               height: 60,
//               child: HeaderRow(
//                 showClubName: true,
//                 headingName: "Setting & Security",
//               ),
//             ),
//
//             // Backlight
//             _buildCard(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Backlight", style: TextStyle(color: Colors.white, fontSize: 16)),
//                   Transform.scale(
//                     scale: 0.8,
//                     child: Switch(
//                       value: backlight,
//                       onChanged: isSendingRequest
//                           ? null
//                           : (value) async {
//                         setState(() => isSendingRequest = true);
//                         await _sendCommand(0x06, value ? 1 : 0, 0x00);
//                         setState(() {
//                           backlight = value;
//                           isSendingRequest = false;
//                         });
//                         await _savePrefs();
//                       },
//                       activeTrackColor: Colors.white,
//                       inactiveTrackColor: Colors.grey,
//                       thumbColor: MaterialStateProperty.resolveWith<Color>((states) => Colors.black),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Sleep Time
//             _buildCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           const Text("Screen Sleep Time:", style: TextStyle(color: Colors.white, fontSize: 16)),
//                           const SizedBox(width: 8),
//                           Text("$sleepTime min", style: const TextStyle(color: Colors.white, fontSize: 16)),
//                         ],
//                       ),
//                       const SizedBox(width: 12),
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () => setState(() => sleepTime++),
//                             child: const Icon(Icons.add, color: Colors.white, size: 22),
//                           ),
//                           const SizedBox(width: 10),
//                           GestureDetector(
//                             onTap: () => setState(() {
//                               if (sleepTime > 1) sleepTime--;
//                             }),
//                             child: const Icon(Icons.remove, color: Colors.white, size: 22),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       onPressed: () async {
//                         await _sendCommand(0x03, sleepTime, 0x00);
//                         await _savePrefs();
//                       },
//                       child: const Text("OK", style: TextStyle(color: Colors.black)),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Units
//             _buildCard(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Units", style: TextStyle(color: Colors.white, fontSize: 16)),
//                   DropdownButton<String>(
//                     dropdownColor: Colors.grey[900],
//                     value: selectedUnit ? "Meters" : "Yards",
//                     underline: const SizedBox(),
//                     items: const [
//                       DropdownMenuItem(value: "Yards", child: Text("Yards", style: TextStyle(color: Colors.white))),
//                       DropdownMenuItem(value: "Meters", child: Text("Meters", style: TextStyle(color: Colors.white))),
//                     ],
//                       onChanged: (value) async {
//                         if (value != null) {
//                           setState(() => selectedUnit = value == "Meters");
//                           await _sendCommand(0x04, value == "Meters" ? 1 : 0, 0x00);
//                           Navigator.pop(context);
//
//                         }
//
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCard({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: child,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_bloc.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_event.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';
import '../../../golf_device/data/services/ble_service.dart';
import '../../../golf_device/domain/entities/device_entity.dart';
import '../../../golf_device/domain/usecases/send_command_usecase.dart';
import '../../../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import '../../../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import '../../../home_screens/presentation/widgets/header/header_row.dart';

class SettingScreen extends StatelessWidget {
  final DeviceEntity connectedDevice;
  final bool selectedUnit;

  const SettingScreen({
    super.key,
    required this.connectedDevice,
    required this.selectedUnit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingBloc>(
      create: (_) => SettingBloc(
        sendCommandUseCase: sl<SendCommandUseCase>(),
        sharedPreferences: sl<SharedPreferences>(),
        bleService: sl<BleService>(),
      )..add(LoadSettingsEvent(
          device: connectedDevice, initialUnit: selectedUnit)),
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        bottomNavigationBar: const BottomNavBar(),
        appBar: const CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 1, color: AppColors.dividerColor),
                  const SizedBox(
                    height: 60,
                    child: HeaderRow(headingName: "Setting & Security"),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: BlocConsumer<SettingBloc, SettingState>(
                      listener: (ctx, state) {
                        if (state is SettingError) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      builder: (ctx, state) {
                        if (state is SettingLoaded) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCard(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Backlight",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 16)),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Switch(
                                          value: state.backlight,
                                          onChanged: state.isSending
                                              ? null
                                              : (v) => ctx
                                              .read<SettingBloc>()
                                              .add(ToggleBacklightEvent(v)),
                                          activeTrackColor: Colors.white,
                                          inactiveTrackColor: Colors.grey,
                                          thumbColor: MaterialStateProperty.resolveWith(
                                                (states) => Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 💤 Sleep Time Card
                                _buildCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Text("Screen Sleep Time:",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16)),
                                              const SizedBox(width: 8),
                                              Text("${state.sleepTime} min",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: state.isSending
                                                    ? null
                                                    : () => ctx
                                                    .read<SettingBloc>()
                                                    .add(UpdateSleepTimeLocally(
                                                    state.sleepTime + 1)),
                                                child: const Icon(Icons.add,
                                                    color: Colors.white, size: 22),
                                              ),
                                              const SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: state.isSending
                                                    ? null
                                                    : () {
                                                  if (state.sleepTime > 1) {
                                                    ctx
                                                        .read<SettingBloc>()
                                                        .add(UpdateSleepTimeLocally(
                                                        state.sleepTime - 1));
                                                  }
                                                },
                                                child: const Icon(Icons.remove,
                                                    color: Colors.white, size: 22),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: state.isSending
                                              ? null
                                              : () => ctx.read<SettingBloc>().add(
                                              SendSleepTimeCommandEvent(
                                                  state.sleepTime)),
                                          child: const Text("OK",
                                              style: TextStyle(color: Colors.black)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 📏 Unit Selection Card
                                _buildCard(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Units",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 16)),
                                      DropdownButton<String>(
                                        dropdownColor: Colors.grey[900],
                                        value: state.meters ? "Meters" : "Yards",
                                        underline: const SizedBox(),
                                        items: const [
                                          DropdownMenuItem(
                                              value: "Yards",
                                              child: Text("Yards",
                                                  style:
                                                  TextStyle(color: Colors.white))),
                                          DropdownMenuItem(
                                              value: "Meters",
                                              child: Text("Meters",
                                                  style:
                                                  TextStyle(color: Colors.white))),
                                        ],
                                        onChanged: state.isSending
                                            ? null
                                            : (value) {
                                          if (value != null) {
                                            ctx.read<SettingBloc>().add(
                                                ChangeUnitEvent(
                                                    value == "Meters"));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is SettingLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),

              /// 🔄 Fullscreen overlay when sending
              BlocBuilder<SettingBloc, SettingState>(
                builder: (ctx, state) {
                  if (state is SettingLoaded && state.isSending) {
                    return Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),

      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
      child: child,
    );
  }
}
