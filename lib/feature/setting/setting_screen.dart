import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ble_command_helper.dart';
import '../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import '../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import '../home_screens/presentation/widgets/header/header_row.dart';

class SettingScreen extends StatefulWidget {
  final DiscoveredDevice? connectedDevice;

  const SettingScreen({super.key, required this.connectedDevice});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool backlight = false;
  int sleepTime = 5; // minutes
  String selectedUnit = "Yards";

  static const String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String writeCharacteristicUuid = "0000fee1-0000-1000-8000-00805f9b34fb";
  static const String notifyCharacteristicUuid = "0000fee2-0000-1000-8000-00805f9b34fb";

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<List<int>>? _characteristicSubscription;
  List<DiscoveredService>? _services = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    if (widget.connectedDevice != null) {
      // _discoverServices(widget.connectedDevice!.id);
    }
  }

  @override
  void dispose() {
    _characteristicSubscription?.cancel();
    super.dispose();
  }

  /// 🔹 Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backlight = prefs.getBool("backlight") ?? false;
      sleepTime = prefs.getInt("sleepTime") ?? 5;
      selectedUnit = prefs.getString("unit") ?? "Yards";
    });
  }

  /// 🔹 Save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("backlight", backlight);
    await prefs.setInt("sleepTime", sleepTime);
    await prefs.setString("unit", selectedUnit);
  }

  void _discoverServices(String deviceId) async {
    try {
      _services = await _ble.discoverServices(deviceId);

      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(notifyCharacteristicUuid),
        deviceId: deviceId,
      );

      await _characteristicSubscription?.cancel();

      _characteristicSubscription = _ble.subscribeToCharacteristic(characteristic).listen((data) {

        print('Data From Setting Scrren ${data}');

        if (data.length >= 3) {
          final cmd = data[2];

          switch (cmd) {
            case 0x03: // Sleep timer set
              print('update data');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("⏳ Sleep time set to $sleepTime min "),
                  duration: const Duration(seconds: 1),
                ),
              );
              break;

            case 0x04: // Unit change
            print('update data');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("📏 Unit updated"),
                  duration: Duration(seconds: 1),
                ),
              );
              break;

            case 0x06: // Backlight ON/OFF
              // print('update data');              ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text("💡 Backlight updated"),
              //     duration: Duration(seconds: 1),
              //   ),
              // );
              break;

            default:
              print("Setting Screen CMD: $cmd");
          }
        }
      }, onError: (error) {

      });
    } catch (e) {

    }
  }
  void _sendCommand(int cmd, int param1, int param2) {
    List<int> packet = [0x47, 0x46, cmd, param1, param2];
    int checksum = 0;
    for (int i = 2; i < packet.length; i++) {
      checksum += packet[i];
    }
    packet.add(checksum & 0xFF);

    print('send yard command');
    print(packet);
    _writeToCharacteristic(packet);
  }

  void _writeToCharacteristic(List<int> data) async {
    // if (widget.connectedDevice == null) return;
    try {
      print(widget.connectedDevice?.id ?? "nullllll");
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(writeCharacteristicUuid),
        deviceId: widget.connectedDevice!.id,
      );


      print('Data123 ${data}');

      await _ble.writeCharacteristicWithoutResponse(
        characteristic,
        value: data,
      );
    } catch (e) {
      print('hello$e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: const BottomNavBar(),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Divider(thickness: 1, color: AppColors.dividerColor),
            SizedBox(
              height: 60,
              child: HeaderRow(
                showClubName: true,
                headingName: "Setting & Security",
              ),
            ),
            // 🔘 Backlight Toggle
            _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Backlight",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Transform.scale(
                    scale: 0.8, // 0.8 = 80% of original size
                    child: Switch(
                      value: backlight,
                      onChanged: (value) async {
                        setState(() => backlight = value);
                        _sendCommand(0x06, value ? 1 : 0, 0x00);
                        await _savePreferences();
                      },
                      activeTrackColor: Colors.white,
                      // track when active
                      inactiveTrackColor: Colors.grey,
                      // track when inactive
                      thumbColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => Colors.black, // thumb always black
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ⏲ Sleep Time
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Screen Sleep Time:",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$sleepTime min",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                sleepTime++;
                              });
                            },
                            child: const Icon(Icons.add, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10), // small gap
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (sleepTime > 1) sleepTime--;
                              });
                            },
                            child: const Icon(Icons.remove, color: Colors.white, size: 22),
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
                      onPressed: () async {
                        _sendCommand(0x03, sleepTime, 0x00);
                        await _savePreferences();
                      },
                      child: const Text("OK",
                          style: TextStyle(color: Colors.black)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 📏 Units Dropdown
            _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Units",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  DropdownButton<String>(
                    dropdownColor: Colors.grey[900],
                    value: selectedUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: "Yards",
                          child: Text("Yards",
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: "Meters",
                          child: Text("Meters",
                              style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (value) async {
                      setState(() => selectedUnit = value!);
                      _sendCommand(
                          0x04, selectedUnit == "Meters" ? 1 : 0, 0x00);
                      await _savePreferences();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}
