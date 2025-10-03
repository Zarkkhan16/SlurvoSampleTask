import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ble_command_helper.dart';
import '../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import '../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import '../home_screens/presentation/widgets/header/header_row.dart';

class SettingScreen extends StatefulWidget {
  final BleHelper bleHelper; // inject BLE helper

  const SettingScreen({super.key, required this.bleHelper});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool backlight = false;
  int sleepTime = 5; // minutes
  String selectedUnit = "Yards";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
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

  /// 🔹 Send BLE command through helper
  Future<void> _sendBleCommand(int cmd, int p1, int p2) async {
    try {
      await widget.bleHelper.sendCommand(cmd, p1, p2);
      debugPrint("✅ Sent BLE Command -> cmd:$cmd p1:$p1 p2:$p2");
    } catch (e) {
      debugPrint("❌ Failed to send BLE command: $e");
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
                        await _sendBleCommand(0x06, value ? 1 : 0, 0x00);
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
                        await _sendBleCommand(0x03, sleepTime, 0x00);
                        await _savePreferences();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Sleep time set to $sleepTime min (saved)")),
                        );
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
                      await _sendBleCommand(
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
