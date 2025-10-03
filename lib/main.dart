
import 'package:flutter/material.dart';


import 'package:google_fonts/google_fonts.dart';
import 'package:onegolf/feature/splash/splash_screen.dart';
import 'core/di/injection_container.dart' as di;
import 'core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dart:async';
import 'core/constants/app_colors.dart';
import 'core/constants/app_images.dart';
import 'core/constants/app_strings.dart';
import 'feature/choose_club_screen/presentation/choose_club_screen_page.dart';
import 'feature/home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import 'feature/home_screens/presentation/widgets/buttons/action_button.dart';
import 'feature/home_screens/presentation/widgets/buttons/session_view_button.dart';
import 'feature/home_screens/presentation/widgets/card/glassmorphism_card.dart';
import 'feature/home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import 'feature/home_screens/presentation/widgets/custom_bar/custom_bar.dart';
import 'feature/home_screens/presentation/widgets/header/header_row.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize dependencies
  // await di.init();
  // Request permissions before running the app
  await requestPermissions();
  runApp(MyApp());
}

// Function to request BLE & location permissions
Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();

  // Optional: check if permissions are denied and show a warning
  bool allGranted = statuses.values.every((status) => status.isGranted);
  if (!allGranted) {
    // You can show a dialog or notification to the user
    print("Some permissions are not granted. BLE may not work properly.");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        textTheme:
        GoogleFonts.oswaldTextTheme(Theme.of(context).textTheme),
      ),
      home:  SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

///for ios
// class GolfData {
//   int battery = 0;            // BYTE 4 (doc) = data[3]
//   int recordNumber = 0;       // BYTE 5-6 (doc) = data[4], data[5]
//   int clubName = 0;           // BYTE 7 (doc) = data[6]
//   double clubSpeed = 0.0;     // BYTE 8-9 (doc) = data[7], data[8]
//   double ballSpeed = 0.0;     // BYTE 10-11 (doc) = data[9], data[10]
//   double carryDistance = 0.0; // BYTE 12-13 (doc) = data[11], data[12]
//   double totalDistance = 0.0; // BYTE 14-15 (doc) = data[13], data[14]
//
//   double get smashFactor => clubSpeed > 0 ? ballSpeed / clubSpeed : 0.0;
//
//   String get batteryStatus {
//     switch (battery) {
//       case 0: return "Blank";
//       case 1: return "Low";
//       case 2: return "Middle";
//       case 3: return "Full";
//       default: return "Unknown";
//     }
//   }
//
//   IconData get batteryIcon {
//     switch (battery) {
//       case 0: return Icons.battery_0_bar;
//       case 1: return Icons.battery_2_bar;
//       case 2: return Icons.battery_4_bar;
//       case 3: return Icons.battery_full;
//       default: return Icons.battery_unknown;
//     }
//   }
//
//   Color get batteryColor {
//     switch (battery) {
//       case 0: return Colors.grey;        // blank
//       case 1: return Colors.redAccent;   // low
//       case 2: return Colors.orangeAccent;// middle
//       case 3: return Colors.greenAccent; // full
//       default: return Colors.white;
//     }
//   }
//
//   String get clubNameString {
//     const clubs = [
//       "1W", "2W", "3W", "5W", "7W", "2H", "3H", "4H", "5H",
//       "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
//       "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
//     ];
//     return clubName <= clubs.length ? clubs[clubName] : "Unknown";
//   }
//
//   String get clubLoftString {
//     const clubLofts = [
//       10, 13, 15, 17, 21,
//       17, 19, 21, 24,
//       14, 18, 21, 23, 26, 29, 33, 37, 41,
//       46, 50, 52, 54, 56, 58, 60
//     ];
//
//     if (clubName >= 0 && clubName < clubLofts.length) {
//       return clubLofts[clubName].toString();
//     } else {
//       return "Unknown";
//     }
//   }
// }
//
// class GolfDeviceScreen extends StatefulWidget {
//   @override
//   _GolfDeviceScreenState createState() => _GolfDeviceScreenState();
// }
//
// class _GolfDeviceScreenState extends State<GolfDeviceScreen> {
//   StreamSubscription<List<ScanResult>>? _scanSubscription;
//   StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
//   StreamSubscription<List<int>>? _characteristicSubscription;
//
//   List<ScanResult> devices = [];
//   bool isScanning = false;
//   bool isConnecting = false;
//   BluetoothConnectionState connectionState = BluetoothConnectionState.disconnected;
//   BluetoothDevice? connectedDevice;
//
//   Timer? syncTimer;
//   GolfData golfData = GolfData();
//   int sleepTime = 1;
//   bool units = false;
//
//   int? selectedClub;
//
//   static const String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
//   static const String writeCharacteristicUuid = "0000fee1-0000-1000-8000-00805f9b34fb";
//   static const String notifyCharacteristicUuid = "0000fee2-0000-1000-8000-00805f9b34fb";
//
//   @override
//   void initState() {
//     super.initState();
//     _checkBleStatus();
//   }
//
//   @override
//   void dispose() {
//     syncTimer?.cancel();
//     _scanSubscription?.cancel();
//     _connectionSubscription?.cancel();
//     _characteristicSubscription?.cancel();
//     super.dispose();
//   }
//
//   void _checkBleStatus() async {
//     // Check if Bluetooth is available
//     if (await FlutterBluePlus.isSupported == false) {
//       _addLog("Bluetooth not supported by this device");
//       return;
//     }
//
//     // Listen to Bluetooth state
//     FlutterBluePlus.adapterState.listen((state) {
//       print('BLE Status: $state');
//       _addLog('BLE Status: $state');
//
//       if (state == BluetoothAdapterState.on) {
//         _scanForDevices();
//       }
//     });
//
//     // Check current state
//     if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on) {
//       _scanForDevices();
//     }
//   }
//
//   List<BluetoothService>? _services = [];
//   List<String>? _logs = [];
//   BluetoothCharacteristic? _writeCharacteristic;
//   BluetoothCharacteristic? _notifyCharacteristic;
//
//   void _addLog(String message) {
//     final timestamp = DateTime.now().toIso8601String();
//     setState(() {
//       _logs?.add("[$timestamp] $message");
//     });
//     print(message);
//   }
//
//   void _scanForDevices() async {
//     if (isScanning) return;
//
//     setState(() {
//       isScanning = true;
//       devices.clear();
//     });
//
//     try {
//       // Start scanning
//       await FlutterBluePlus.startScan(
//         timeout: Duration(seconds: 10),
//         androidUsesFineLocation: false,
//       );
//
//       // Listen to scan results
//       _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
//         for (ScanResult result in results) {
//           final device = result.device;
//           final name = device.platformName;
//
//           if (name.isNotEmpty && (name.startsWith("A-1LM-") || name.contains("BM"))) {
//             final existingIndex = devices.indexWhere((d) => d.device.remoteId == device.remoteId);
//             setState(() {
//               if (existingIndex >= 0) {
//                 devices[existingIndex] = result;
//               } else {
//                 devices.add(result);
//               }
//             });
//           }
//         }
//       }, onError: (error) {
//         print('Scan error: $error');
//         _addLog('Scan error: $error');
//       });
//
//       // Stop scanning after timeout
//       await Future.delayed(Duration(seconds: 10));
//       _stopScanning();
//     } catch (e) {
//       print('Error starting scan: $e');
//       _addLog('Error starting scan: $e');
//       setState(() {
//         isScanning = false;
//       });
//     }
//   }
//
//   void _stopScanning() async {
//     try {
//       await FlutterBluePlus.stopScan();
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//     setState(() {
//       isScanning = false;
//     });
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     if (isConnecting) return;
//
//     setState(() {
//       isConnecting = true;
//     });
//
//     try {
//       // Connect to device
//       await device.connect(timeout: Duration(seconds: 10));
//
//       // Listen to connection state
//       _connectionSubscription = device.connectionState.listen((state) {
//         setState(() {
//           connectionState = state;
//         });
//
//         if (state == BluetoothConnectionState.connected) {
//           setState(() {
//             isConnecting = false;
//             connectedDevice = device;
//           });
//
//           _discoverServices(device);
//           _startSyncTimer();
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Connected to ${device.platformName}')),
//           );
//         } else if (state == BluetoothConnectionState.disconnected) {
//           setState(() {
//             isConnecting = false;
//             connectedDevice = null;
//           });
//           _characteristicSubscription?.cancel();
//           syncTimer?.cancel();
//         }
//       });
//     } catch (e) {
//       setState(() {
//         isConnecting = false;
//         connectionState = BluetoothConnectionState.disconnected;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to connect: $e')),
//       );
//     }
//   }
//
//   void _discoverServices(BluetoothDevice device) async {
//     try {
//       // Add a small delay to ensure connection is stable
//       await Future.delayed(Duration(milliseconds: 500));
//
//       _services = await device.discoverServices();
//       _addLog("Discovered ${_services?.length} services");
//
//       if (_services == null || _services!.isEmpty) {
//         _addLog("✗ No services discovered!");
//         return;
//       }
//
//       for (var service in _services ?? []) {
//         _addLog("Service: ${service.uuid}");
//         // for (var c in service.characteristics) {
//         //   String props = "";
//         //   if (c.properties.read) props += "R ";
//         //   if (c.properties.write) props += "W ";
//         //   if (c.properties.writeWithoutResponse) props += "WNR ";
//         //   if (c.properties.notify) props += "N ";
//         //   if (c.properties.indicate) props += "I ";
//         //   _addLog("  Char: ${c.uuid}, props: $props");
//         //
//         //   // Store characteristics for later use
//         //   // Compare using contains() to handle both short and long UUID formats
//         //   String charUuidStr = c.uuid.toString().toLowerCase();
//         //
//         //   if (charUuidStr.contains("fee1")) {
//         //     if (c.properties.write || c.properties.writeWithoutResponse) {
//         //       _writeCharacteristic = c;
//         //       _addLog("  ✓ Stored as WRITE characteristic");
//         //     }
//         //   }
//         //   if (charUuidStr.contains("fee2")) {
//         //     if (c.properties.notify || c.properties.indicate) {
//         //       _notifyCharacteristic = c;
//         //       _addLog("  ✓ Stored as NOTIFY characteristic");
//         //     }
//         //   }
//         // }
//       }
//       setState(() {});
//
//       // If we didn't find characteristics by UUID, try to find any writable one
//       if (_writeCharacteristic == null) {
//         _addLog("⚠ Write characteristic not found by UUID, searching for any writable characteristic...");
//         for (var service in _services ?? []) {
//           if (service.uuid.toString().toLowerCase().contains("ffe0")) {
//             for (var char in service.characteristics) {
//               if (char.properties.write || char.properties.writeWithoutResponse) {
//                 _writeCharacteristic = char;
//                 _addLog("✓ Found writable characteristic: ${char.uuid}");
//                 break;
//               }
//             }
//           }
//         }
//       }
//
//       // Setup notifications if characteristic found
//       if (_notifyCharacteristic != null) {
//         await _notifyCharacteristic!.setNotifyValue(true);
//         _addLog("✓ Notifications enabled on ${_notifyCharacteristic!.uuid}");
//
//         _characteristicSubscription = _notifyCharacteristic!.lastValueStream.listen((data) {
//           print('Data From Device $data');
//           if (data.isNotEmpty) {
//             _addLog("Notify <- ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
//           }
//
//           if (data.length >= 3) {
//             final cmd = data[2];
//
//             switch (cmd) {
//               case 0x01: // Sync data (golf stats)
//                 if (data.length >= 16) {
//                   _parseGolfData(Uint8List.fromList(data));
//                 }
//                 break;
//
//               case 0x02: // Club name update
//                 setState(() {
//                   isLoading = false;
//                   _isPaused = false;
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("✅ Club name updated"),
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//                 break;
//
//               case 0x03: // Sleep timer set
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("⏳ Sleep timer set"),
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//                 break;
//
//               case 0x04: // Unit change
//                 setState(() {
//                   units = !units;
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text("📏 Unit updated"),
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//                 break;
//
//               case 0x06: // Backlight ON/OFF
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text("💡 Backlight updated"),
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//                 break;
//
//               default:
//                 print("Unknown CMD: $cmd");
//             }
//           }
//         }, onError: (error) {
//           _addLog('Characteristic subscription error: $error');
//           setState(() {
//             isLoading = false;
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       _addLog('Error discovering services: $e');
//     }
//   }
//
//   bool isLoading = false;
//   bool _isPaused = false;
//
//   void _disconnect() async {
//     if (connectedDevice != null) {
//       await connectedDevice!.disconnect();
//     }
//     _connectionSubscription?.cancel();
//     _characteristicSubscription?.cancel();
//     syncTimer?.cancel();
//     setState(() {
//       connectionState = BluetoothConnectionState.disconnected;
//       connectedDevice = null;
//       _writeCharacteristic = null;
//       _notifyCharacteristic = null;
//       _services = [];
//     });
//   }
//
//   void _startSyncTimer() {
//     syncTimer?.cancel();
//     syncTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_isPaused == true) print('pause1');
//       if (_isPaused != true) {
//         _sendSyncPacket();
//       }
//     });
//   }
//
//   void _sendSyncPacket() {
//     if (_isPaused) print('pause');
//     if (connectedDevice == null || connectionState != BluetoothConnectionState.connected) return;
//
//     int clubId = golfData.clubName;
//     int checksum = (0x01 + clubId + 0x00) & 0xFF;
//
//     print("Club Number $clubId");
//     print("Sum $checksum");
//
//     List<int> syncPacket = [
//       0x47, 0x46,       // Header "GF"
//       0x01,             // CMD = sync
//       clubId,           // current club id
//       0x00,             // reserved
//       checksum,         // checksum
//     ];
//     _writeToCharacteristic(syncPacket);
//   }
//
//   void _sendCommand(int cmd, int param1, int param2) {
//     if (connectedDevice == null || connectionState != BluetoothConnectionState.connected) return;
//
//     setState(() {
//       isLoading = true;
//       _isPaused = true;
//     });
//
//     List<int> packet = [0x47, 0x46, cmd, param1, param2];
//     int checksum = 0;
//     for (int i = 2; i < packet.length; i++) {
//       checksum += packet[i];
//     }
//     packet.add(checksum & 0xFF);
//
//     print('?????????');
//     print(packet);
//     _writeToCharacteristic(packet);
//   }
//
//   void _writeToCharacteristic(List<int> data) async {
//     if (connectedDevice == null) {
//       _addLog("✗ Cannot write: No connected device");
//       return;
//     }
//
//     if (_writeCharacteristic == null) {
//       _addLog("✗ Cannot write: Write characteristic not initialized");
//       _addLog("  Services count: ${_services?.length ?? 0}");
//
//       // Try to find it again
//       if (_services != null && _services!.isNotEmpty) {
//         _addLog("  Attempting to find write characteristic again...");
//         for (var service in _services!) {
//           _addLog("  Checking service: ${service.uuid}");
//           for (var char in service.characteristics) {
//             _addLog("    Char: ${char.uuid}");
//             if (char.properties.write || char.properties.writeWithoutResponse) {
//               _writeCharacteristic = char;
//               _addLog("    ✓ Found and stored writable characteristic!");
//               break;
//             }
//           }
//           if (_writeCharacteristic != null) break;
//         }
//       }
//
//       if (_writeCharacteristic == null) {
//         _addLog("✗✗✗ NO WRITABLE CHARACTERISTIC FOUND!");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('No writable characteristic found')),
//         );
//         return;
//       }
//     }
//
//     try {
//       _addLog("Write -> ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
//       print('Writing to ${_writeCharacteristic!.uuid}');
//       print('Data: $data');
//
//       // Use the appropriate write method based on properties
//       if (_writeCharacteristic!.properties.writeWithoutResponse) {
//         await _writeCharacteristic!.write(data, withoutResponse: true);
//         _addLog("✓ Written without response");
//       } else if (_writeCharacteristic!.properties.write) {
//         await _writeCharacteristic!.write(data, withoutResponse: false);
//         _addLog("✓ Written with response");
//       }
//     } catch (e) {
//       _addLog('✗ Write error: $e');
//       _writeCharacteristic = null; // Reset so it can be rediscovered
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Write failed: $e')),
//       );
//     }
//   }
//
//   void _parseGolfData(Uint8List data) {
//     if (data.length < 15 || data[0] != 0x47 || data[1] != 0x46) return;
//
//     setState(() {
//       golfData.battery = data[3];
//       print("Battery Raw: ${data[3]}");
//
//       // Record number = little endian
//       golfData.recordNumber = (data[4] << 8) | data[5];
//
//       golfData.clubName = data[6];
//
//       // Club/ball speed, distances = big endian
//       golfData.clubSpeed = (((data[7] << 8) | data[8]) / 10.0);
//       golfData.ballSpeed = (((data[9] << 8) | data[10]) / 10.0);
//       golfData.carryDistance = (((data[11] << 8) | data[12]) / 10.0);
//       golfData.totalDistance = (((data[13] << 8) | data[14]) / 10.0);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     return connectionState == BluetoothConnectionState.connected
//         ? Scaffold(
//         backgroundColor: AppColors.primaryBackground,
//         bottomNavigationBar: const BottomNavBar(),
//
//         body: _buildConnectedView())
//         : Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(
//           "Scanned Devices",
//           style: TextStyle(
//               fontSize: w * 0.05,
//               fontWeight: FontWeight.w600,
//               color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             onPressed: _scanForDevices,
//             icon: const Icon(Icons.refresh),
//           )
//         ],
//       ),
//       body: Container(
//         color: Colors.black,
//         child: isScanning || isConnecting
//             ? _centerMessage(
//           w,
//           isConnecting ? "Connecting..." : "Scanning for devices...",
//           showLoader: true,
//         )
//             : devices.isEmpty
//             ? _centerMessage(w, "No devices found", showRetry: true)
//             : Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(w * 0.04),
//               child: Text(
//                 "Found ${devices.length} device${devices.length == 1 ? '' : 's'}",
//                 style: TextStyle(
//                     color: Colors.white70, fontSize: w * 0.035),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: devices.length,
//                 itemBuilder: (context, index) {
//                   final result = devices[index];
//                   final device = result.device;
//                   final rssi = result.rssi;
//                   return Card(
//                     margin: EdgeInsets.symmetric(
//                         horizontal: w * 0.04, vertical: w * 0.01),
//                     color: Colors.grey[900],
//                     child: ListTile(
//                       leading: Icon(
//                         Icons.bluetooth,
//                         color: _getSignalColor(rssi),
//                         size: w * 0.06,
//                       ),
//                       title: Text(
//                         device.platformName.isNotEmpty
//                             ? device.platformName
//                             : "Unknown Device",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       subtitle: Text(
//                         "ID: ${device.remoteId}\nSignal: $rssi dBm ${_getSignalStrength(rssi)}",
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                       trailing: const Icon(
//                         Icons.arrow_forward_ios,
//                         color: Colors.white54,
//                         size: 16,
//                       ),
//                       onTap: () => _connectToDevice(device),
//                     ),
//                   );
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _centerMessage(double w, String message,
//       {bool showLoader = false, bool showRetry = false}) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (showLoader) const CircularProgressIndicator(color: Colors.white),
//           SizedBox(height: w * 0.04),
//           Text(message,
//               style: TextStyle(color: Colors.white, fontSize: w * 0.045),
//               textAlign: TextAlign.center),
//           if (showRetry)
//             Padding(
//               padding: EdgeInsets.only(top: w * 0.04),
//               child: ElevatedButton(
//                 onPressed: _scanForDevices,
//                 child: const Text("Retry Scan"),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Color _getSignalColor(int rssi) => rssi >= -50
//       ? Colors.green
//       : rssi >= -70
//       ? Colors.orange
//       : Colors.red;
//
//   String _getSignalStrength(int rssi) => rssi >= -50
//       ? "(Excellent)"
//       : rssi >= -70
//       ? "(Good)"
//       : "(Weak)";
//
//   static const List<String> clubs = [
//     "1W", "2W", "3W", "5W", "7W",
//     "2H", "3H", "4H", "5H",
//     "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
//     "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
//   ];
//
//   Widget _buildConnectedView() {
//     return Column(
//       children: [
//         const Divider(thickness: 1, color: AppColors.dividerColor),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 60,
//                   child: HeaderRow(
//                     showClubName: true,
//                     goScanScreen: true,
//                     headingName: "Shot Analysis",
//                     selectedClub: Club(
//                         code: golfData.clubName.toString(),
//                         name: clubs[golfData.clubName]),
//                     onClubSelected: (value) {
//                       setState(() {
//                         golfData.clubName = int.parse(value.code);
//                         isLoading = true;
//                       });
//                       _sendCommand(0x02, int.parse(value.code), 0x00);
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 const CustomizeBar(),
//                 const SizedBox(height: 15),
//                 isLoading
//                     ? Center(
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                     ))
//                     : Expanded(
//                   child: _golfMetrics.isEmpty
//                       ? const Center(
//                     child: Text(
//                       "No shot data received yet",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   )
//                       : GridView.builder(
//                     padding: const EdgeInsets.all(16),
//                     gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 30,
//                       mainAxisSpacing: 20,
//                       childAspectRatio: 1.42,
//                     ),
//                     itemCount: _golfMetrics.length,
//                     itemBuilder: (context, index) {
//                       final shot = _golfMetrics[index];
//                       return GlassmorphismCard(
//                         value: shot["value"]!,
//                         name: shot["metric"]!,
//                         unit: shot["unit"]!,
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       ActionButton(
//                         text: AppStrings.deleteShotText,
//                         onPressed: () {},
//                       ),
//                       ActionButton(
//                         svgAssetPath: AppImages.groupIcon,
//                         text: AppStrings.dispersionText,
//                         onPressed: () {},
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 17),
//                 const SessionViewButton(),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   List<Map<String, String>> get _golfMetrics {
//     return [
//       {
//         "metric": "Club Speed",
//         "value": golfData.clubSpeed.toStringAsFixed(1),
//         "unit": "MPH",
//       },
//       {
//         "metric": "Ball Speed",
//         "value": golfData.ballSpeed.toStringAsFixed(1),
//         "unit": "MPH",
//       },
//       {
//         "metric": "Carry Distance",
//         "value": golfData.carryDistance.toStringAsFixed(1),
//         "unit": units ? "M" : "YDS",
//       },
//       {
//         "metric": "Total Distance",
//         "value": golfData.totalDistance.toStringAsFixed(1),
//         "unit": units ? "M" : "YDS",
//       },
//       {
//         "metric": "Smash Factor",
//         "value": golfData.smashFactor.toStringAsFixed(2),
//         "unit": "",
//       },
//     ];
//   }
// }
//
//


// import 'package:flutter/material.dart';


// import 'package:google_fonts/google_fonts.dart';
// import 'package:onegolf/feature/splash/splash_screen.dart';
// import 'core/di/injection_container.dart' as di;
// import 'core/constants/app_strings.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Initialize dependencies
//   // await di.init();
//   // Request permissions before running the app
//   await requestPermissions();
//   runApp(MyApp());
// }
//
// // Function to request BLE & location permissions
// Future<void> requestPermissions() async {
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.bluetoothScan,
//     Permission.bluetoothConnect,
//     Permission.location,
//   ].request();
//
//   // Optional: check if permissions are denied and show a warning
//   bool allGranted = statuses.values.every((status) => status.isGranted);
//   if (!allGranted) {
//     // You can show a dialog or notification to the user
//     print("Some permissions are not granted. BLE may not work properly.");
//   }
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: AppStrings.appTitle,
//       theme: ThemeData(
//         textTheme:
//         GoogleFonts.oswaldTextTheme(Theme.of(context).textTheme),
//       ),
//       home: const SplashScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
///for ios

///
//
// import 'package:onegolf/log.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:typed_data';
// import 'dart:async';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await _requestPermissions();
//   runApp(GolfApp());
// }
//
// Future<void> _requestPermissions() async {
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.bluetooth,
//     Permission.bluetoothScan,
//     Permission.bluetoothConnect,
//     Permission.bluetoothAdvertise,
//     Permission.location,
//     Permission.locationWhenInUse,
//   ].request();
//
//   bool allGranted = true;
//   statuses.forEach((permission, status) {
//     if (status != PermissionStatus.granted) {
//       print('Permission $permission denied: $status');
//       allGranted = false;
//     }
//   });
//
//   if (!allGranted) {
//     print('Some permissions were denied. The app may not work properly.');
//   }
// }
//
// class GolfApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Golf Device',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark().copyWith(
//         primaryColor: Colors.grey[900],
//         scaffoldBackgroundColor: Colors.black,
//         appBarTheme: AppBarTheme(
//           backgroundColor: Colors.grey[850],
//           foregroundColor: Colors.white,
//         ),
//         cardColor: Colors.grey[850],
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.grey[800],
//             foregroundColor: Colors.white,
//           ),
//         ),
//         snackBarTheme: SnackBarThemeData(
//           backgroundColor: Colors.grey[800],
//           contentTextStyle: TextStyle(color: Colors.white),
//         ),
//       ),
//       home: GolfDeviceScreen(),
//     );
//   }
// }
//
// class GolfData {
//   int battery = 0;            // BYTE 4 (doc) = data[3]
//   int recordNumber = 0;       // BYTE 5-6 (doc) = data[4], data[5]
//   int clubName = 0;           // BYTE 7 (doc) = data[6]
//   double clubSpeed = 0.0;     // BYTE 8-9 (doc) = data[7], data[8]
//   double ballSpeed = 0.0;     // BYTE 10-11 (doc) = data[9], data[10]
//   double carryDistance = 0.0; // BYTE 12-13 (doc) = data[11], data[12]
//   double totalDistance = 0.0; // BYTE 14-15 (doc) = data[13], data[14]
//
//   double get smashFactor => clubSpeed > 0 ? ballSpeed / clubSpeed : 0.0;
//
//   String get batteryStatus {
//     switch (battery) {
//       case 0: return "Blank";
//       case 1: return "Low";
//       case 2: return "Middle";
//       case 3: return "Full";
//       default: return "Unknown";
//     }
//   }
//
//   IconData get batteryIcon {
//     switch (battery) {
//       case 0: return Icons.battery_0_bar;
//       case 1: return Icons.battery_2_bar;
//       case 2: return Icons.battery_4_bar;
//       case 3: return Icons.battery_full;
//       default: return Icons.battery_unknown;
//     }
//   }
//
//   Color get batteryColor {
//     switch (battery) {
//       case 0: return Colors.grey;        // blank
//       case 1: return Colors.redAccent;   // low
//       case 2: return Colors.orangeAccent;// middle
//       case 3: return Colors.greenAccent; // full
//       default: return Colors.white;
//     }
//   }
//
//   String get clubNameString {
//     const clubs = [
//       "1W", "2W", "3W", "5W", "7W", "2H", "3H", "4H", "5H",
//       "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
//       "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
//     ];
//     return clubName <= clubs.length ? clubs[clubName] : "Unknown";
//   }
//
//   String get clubLoftString {
//     const clubLofts = [
//       10, 13, 15, 17, 21,
//       17, 19, 21, 24,
//       14, 18, 21, 23, 26, 29, 33, 37, 41,
//       46, 50, 52, 54, 56, 58, 60
//     ];
//
//     if (clubName >= 0 && clubName < clubLofts.length) {
//       return clubLofts[clubName].toString(); // return as String
//     } else {
//       return "Unknown";
//     }
//
//   }
// }
//
// class GolfDeviceScreen extends StatefulWidget {
//   @override
//   _GolfDeviceScreenState createState() => _GolfDeviceScreenState();
// }
//
// class _GolfDeviceScreenState extends State<GolfDeviceScreen> {
//   final FlutterReactiveBle _ble = FlutterReactiveBle();
//
//   StreamSubscription<DiscoveredDevice>? _scanSubscription;
//   StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
//   StreamSubscription<List<int>>? _characteristicSubscription;
//
//   List<DiscoveredDevice> devices = [];
//   bool isScanning = false;
//   bool isConnecting = false;
//   DeviceConnectionState connectionState = DeviceConnectionState.disconnected;
//   DiscoveredDevice? connectedDevice;
//
//   Timer? syncTimer;
//   GolfData golfData = GolfData();
//   int sleepTime = 1;
//   bool units = false;
//
//   int? selectedClub;
//
//   static const String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
//   static const String writeCharacteristicUuid = "0000fee1-0000-1000-8000-00805f9b34fb";
//   static const String notifyCharacteristicUuid = "0000fee2-0000-1000-8000-00805f9b34fb";
//
//   @override
//   void initState() {
//     super.initState();
//     _checkBleStatus();
//   }
//
//   @override
//   void dispose() {
//     syncTimer?.cancel();
//     _scanSubscription?.cancel();
//     _connectionSubscription?.cancel();
//     _characteristicSubscription?.cancel();
//     super.dispose();
//   }
//
//   void _checkBleStatus() async {
//     _ble.statusStream.listen((status) {
//       print('BLE Status: $status');
//       _addLog('BLE Status: $status');
//
//       if (status == BleStatus.ready) {
//         _scanForDevices();
//       }
//     });
//   }
//   List<DiscoveredService>? _services = [];
//   List<String>? _logs = [];
//
//   void _addLog(String message) {
//     final timestamp = DateTime.now().toIso8601String();
//     setState(() {
//       _logs?.add("[$timestamp] $message");
//     });
//     print(message); // still goes to console
//   }
//
//   void _scanForDevices() {
//     if (isScanning) return;
//     setState(() {
//       isScanning = true;
//       devices.clear();
//     });
//
//     _scanSubscription?.cancel();
//     _scanSubscription = _ble.scanForDevices(
//       withServices: [],
//       scanMode: ScanMode.lowLatency,
//       requireLocationServicesEnabled: false,
//     ).listen((device) {
//       if (device.name.isNotEmpty && (device.name.startsWith("A-1LM-")||device.name.contains("BM"))) {
//         final existingIndex = devices.indexWhere((d) => d.id == device.id);
//         setState(() {
//           if (existingIndex >= 0) {
//             devices[existingIndex] = device;
//           } else {
//             devices.add(device);
//           }
//         });
//       }
//     }, onError: (error) {
//       print('Scan error: $error');
//     });
//
//     Timer(Duration(seconds: 10), () {
//       _stopScanning();
//     });
//   }
//
//   void _stopScanning() {
//     _scanSubscription?.cancel();
//     setState(() {
//       isScanning = false;
//     });
//   }
//
//   void _connectToDevice(DiscoveredDevice device) async {
//     if (isConnecting) return;
//     setState(() {
//       isConnecting = true;
//     });
//
//     _connectionSubscription?.cancel();
//     _connectionSubscription = _ble.connectToDevice(
//       id: device.id,
//       connectionTimeout: Duration(seconds: 10),
//     ).listen((connectionStateUpdate) {
//       setState(() {
//         connectionState = connectionStateUpdate.connectionState;
//       });
//
//       if (connectionStateUpdate.connectionState == DeviceConnectionState.connected) {
//         setState(() {
//           isConnecting = false;
//           connectedDevice = device;
//         });
//
//         _discoverServices(device.id);
//         _startSyncTimer();
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Connected to ${device.name}')),
//         );
//       } else if (connectionStateUpdate.connectionState == DeviceConnectionState.disconnected) {
//         setState(() {
//           isConnecting = false;
//           connectedDevice = null;
//         });
//         _characteristicSubscription?.cancel();
//         syncTimer?.cancel();
//       }
//     }, onError: (error) {
//       setState(() {
//         isConnecting = false;
//         connectionState = DeviceConnectionState.disconnected;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to connect: $error')),
//       );
//     });
//   }
//
//   ///v2
//   void _discoverServices(String deviceId) async {
//     try {
//       _services = await _ble.discoverServices(deviceId);
//       _addLog("Discovered ${_services?.length} services");
//       for (var service in _services??[]) {
//         _addLog("Service: ${service.serviceId}");
//         for (var c in service.characteristics) {
//           _addLog("  Char: ${c.characteristicId}, props: ${c.isReadable ? "R" : ""}${c.isWritableWithoutResponse ? " W" : ""}${c.isNotifiable ? " N" : ""}");
//         }
//         setState(() {});
//       }
//
//       final characteristic = QualifiedCharacteristic(
//         serviceId: Uuid.parse(serviceUuid),
//         characteristicId: Uuid.parse(notifyCharacteristicUuid),
//         deviceId: deviceId,
//       );
//
//       _characteristicSubscription = _ble.subscribeToCharacteristic(characteristic).listen((data) {
//
//         print('Data From Device ${data}');
//         if (data.isNotEmpty) {
//           _addLog("Notify <- ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
//         }
//
//         if (data.length >= 3) {
//           final cmd = data[2];
//
//           switch (cmd) {
//             case 0x01: // Sync data (golf stats)
//               if (data.length >= 16) {
//                 _parseGolfData(Uint8List.fromList(data));
//               }
//               break;
//
//             case 0x02: // Club name update
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("✅ Club name updated"),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//               break;
//
//             case 0x03: // Sleep timer set
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("⏳ Sleep timer set"),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//               break;
//
//             case 0x04: // Unit change
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text("📏 Unit updated"),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//               break;
//
//             case 0x06: // Backlight ON/OFF
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text("💡 Backlight updated"),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//               break;
//
//             default:
//               print("Unknown CMD: $cmd");
//           }
//         }
//         // if (data.length >= 16) {
//         //   // final testPacket = [
//         //   //   0x47, 0x46, 0x01, 0x01, 0x00, 0x1E, 0x00,
//         //   //   0x04, 0x8A, 0x06, 0x9F, 0x0B, 0x36, 0x0B, 0xF0, 0x7F
//         //   // ];
//         //   // _parseGolfData(Uint8List.fromList([71, 70, 1, 1, 0, 30, 4, 4, 138, 6, 159, 11, 54, 11, 240, 127]));
//         //   _parseGolfData(Uint8List.fromList(data));
//         // }
//       }, onError: (error) {
//         _addLog('Characteristic subscription error: $error');
//       });
//     } catch (e) {
//       _addLog('Error discovering services: $e');
//     }
//   }
//
//   void _disconnect() {
//     _connectionSubscription?.cancel();
//     _characteristicSubscription?.cancel();
//     syncTimer?.cancel();
//     setState(() {
//       connectionState = DeviceConnectionState.disconnected;
//       connectedDevice = null;
//     });
//   }
//
//   void _startSyncTimer() {
//     syncTimer?.cancel();
//     syncTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _sendSyncPacket();
//     });
//   }
//
//   void _sendSyncPacket() {
//     if (connectedDevice == null || connectionState != DeviceConnectionState.connected) return;
//     int clubId = golfData.clubName; // <-- your current club index
//     int checksum = (0x01 + clubId + 0x00) & 0xFF; // sum of bytes 3~5
//
//     print("Club Number ${clubId}");
//     print("Sum ${checksum}");
//
//     // List<int> syncPacket = [0x47, 0x46, 0x01, 0x00, 0x00, 0x01];
//
//     List<int> syncPacket = [
//       0x47, 0x46,       // Header "GF"
//       0x01,             // CMD = sync
//       clubId,           // current club id
//       0x00,             // reserved
//       checksum,         // checksum
//     ];
//     _writeToCharacteristic(syncPacket);
//   }
//
//   void _sendCommand(int cmd, int param1, int param2) {
//     if (connectedDevice == null || connectionState != DeviceConnectionState.connected) return;
//
//     List<int> packet = [0x47, 0x46, cmd, param1, param2];
//     int checksum = 0;
//     for (int i = 2; i < packet.length; i++) {
//       checksum += packet[i];
//     }
//     packet.add(checksum & 0xFF);
//
//     print('?????????');
//     print(packet);
//     _writeToCharacteristic(packet);
//   }
// /// v1
//   // void _writeToCharacteristic(List<int> data) async {
//   //   if (connectedDevice == null) return;
//   //   try {
//   //     final characteristic = QualifiedCharacteristic(
//   //       serviceId: Uuid.parse(serviceUuid),
//   //       characteristicId: Uuid.parse(writeCharacteristicUuid),
//   //       deviceId: connectedDevice!.id,
//   //     );
//   //     await _ble.writeCharacteristicWithoutResponse(
//   //       characteristic,
//   //       value: data,
//   //     );
//   //   } catch (e) {
//   //     print('Write error: $e');
//   //   }
//   // }
//   ///v2
//   void _writeToCharacteristic(List<int> data) async {
//     if (connectedDevice == null) return;
//     try {
//       final characteristic = QualifiedCharacteristic(
//         serviceId: Uuid.parse(serviceUuid),
//         characteristicId: Uuid.parse(writeCharacteristicUuid),
//         deviceId: connectedDevice!.id,
//       );
//
//       _addLog("Write -> ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
//
//       print('Data ${data}');
//
//       await _ble.writeCharacteristicWithoutResponse(
//         characteristic,
//         value: data,
//       );
//     } catch (e) {
//       _addLog('Write error: $e');
//     }
//   }
// ///v2
//   void _parseGolfData(Uint8List data) {
//
//     if (data.length < 15 || data[0] != 0x47 || data[1] != 0x46) return;
//     setState(() {
//       golfData.battery = data[3];                           // BYTE 4
//
//       // Record number = little endian
//       golfData.recordNumber = (data[4] << 8) | data[5];
//
//       golfData.clubName = data[6];                         // BYTE 7
//
//       // Club/ball speed, distances = big endian
//       golfData.clubSpeed = (((data[7] << 8) | data[8]) / 10.0);
//       golfData.ballSpeed = (((data[9] << 8) | data[10]) / 10.0);
//       golfData.carryDistance = (((data[11] << 8) | data[12]) / 10.0);
//       golfData.totalDistance = (((data[13] << 8) | data[14]) / 10.0);
//     });
//
//
//   }
//
//
//   ///v1
//   // void _parseGolfData(Uint8List data) {
//   //   if (data.length < 16 || data[0] != 0x47 || data[1] != 0x46) return;
//   //   setState(() {
//   //     golfData.battery = data[3];
//   //     golfData.recordNumber = data[5] | (data[6] << 8);
//   //     golfData.clubName = data[7];
//   //     golfData.clubSpeed = ((data[8] | (data[9] << 8)) / 10.0);
//   //     golfData.ballSpeed = ((data[10] | (data[11] << 8)) / 10.0);
//   //     golfData.carryDistance = ((data[12] | (data[13] << 8)) / 10.0);
//   //     golfData.totalDistance = ((data[14] | (data[15] << 8)) / 10.0);
//   //   });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Golf Device'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.list_alt),
//             tooltip: "View Logs",
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => LogScreen(services: _services??[], logs: _logs??[]),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//
//
//
//       body: Container(
//         color: Colors.black,
//         child: connectionState == DeviceConnectionState.connected
//             ? _buildConnectedView()
//             : _buildConnectionView(),
//       ),
//     );
//   }
// ///v2
//   Widget _buildConnectionView() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Icon(Icons.bluetooth, size: 64, color: Colors.greenAccent),
//                   SizedBox(height: 16),
//                   Text(
//                     'Available Golf Devices',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 16),
//                   if (devices.isEmpty && !isScanning)
//                     Text('No golf devices found. Please scan for devices.')
//                   else if (isScanning)
//                     Column(
//                       children: [
//                         CircularProgressIndicator(),
//                         SizedBox(height: 8),
//                         Text('Scanning for devices...'),
//                       ],
//                     )
//                   else
//                     ...devices.map((device) => ListTile(
//                       leading: Icon(Icons.golf_course, color: Colors.white),
//                       title: Text(device.name),
//                       subtitle: Text('${device.id}\nRSSI: ${device.rssi} dBm'),
//                       trailing: isConnecting
//                           ? CircularProgressIndicator()
//                           : Icon(Icons.chevron_right, color: Colors.white),
//                       onTap: () => _connectToDevice(device),
//                     )),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isScanning ? _stopScanning : _scanForDevices,
//                   child: Text(isScanning ? 'Stop Scanning' : 'Scan for Devices'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   static const List<String> clubs = [
//     "1W", "2W", "3W", "5W", "7W",
//     "2H", "3H", "4H", "5H",
//     "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
//     "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
//   ];
// ///v1
//   Widget _buildConnectedView() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Text("Club: "),
//               SizedBox(width: 8),
//               Expanded(
//                 child: DropdownButton<int>(
//                   value: golfData.clubName, // current club
//                   isExpanded: true,
//                   items: List.generate(
//                     clubs.length,
//                         (index) => DropdownMenuItem(
//                       value: index,
//                       child: Text(clubs[index]),
//                     ),
//                   ),
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           selectedClub = value;
//                           golfData.clubName = value; // keep UI consistent
//                         });
//                         _sendCommand(0x02, value, 0x00);
//                       }
//                     },
//                 ),
//               ),
//             ],
//           ),
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       children: [
//                         Icon(
//                           golfData.batteryIcon,
//                           color: golfData.batteryColor,
//                           size: 32,
//                         ),
//                         Text(golfData.batteryStatus),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       children: [
//                         Icon(Icons.golf_course, size: 32, color: Colors.greenAccent),
//                         Text("${golfData.clubNameString} (${golfData.clubLoftString})"),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       children: [
//                         Icon(Icons.numbers, size: 32, color: Colors.blueAccent),
//                         Text('Shot #${golfData.recordNumber}'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: Card(
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Icon(Icons.speed, size: 40, color: Colors.blueAccent),
//                         SizedBox(height: 8),
//                         Text(
//                           '${golfData.clubSpeed.toStringAsFixed(1)}',
//                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         Text('Club Speed (MPH)'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Card(
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Icon(Icons.sports_baseball, size: 40, color: Colors.orangeAccent),
//                         SizedBox(height: 8),
//                         Text(
//                           '${golfData.ballSpeed.toStringAsFixed(1)}',
//                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         Text('Ball Speed (MPH)'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: Card(
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Icon(Icons.flag, size: 40, color: Colors.greenAccent),
//                         SizedBox(height: 8),
//                         Text(
//                           '${golfData.carryDistance.toStringAsFixed(1)}',
//                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         Text('Carry Distance (${units ? "m" : "yds"})'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Card(
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Icon(Icons.golf_course, size: 40, color: Colors.purpleAccent),
//                         SizedBox(height: 8),
//                         Text(
//                           '${golfData.totalDistance.toStringAsFixed(1)}',
//                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         Text('Total Distance (${units ? "m" : "yds"})'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Icon(Icons.insights, size: 40, color: Colors.amberAccent),
//                   SizedBox(height: 8),
//                   Text(
//                     '${golfData.smashFactor.toStringAsFixed(2)}',
//                     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                   ),
//                   Text('Smash Factor'),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               units = !units;
//                             });
//                             _sendCommand(0x04, units ? 1 : 0, 0x00);
//                           },
//                           child: Text(units ? 'Switch to Yards' : 'Switch to Meters'),
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             _sendCommand(0x05, 0x00, 0x00);
//                           },
//                           child: Text('Clear Records'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => _sendCommand(0x06, 1, 0x00),
//                           child: Text('Backlight ON'),
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => _sendCommand(0x06, 0, 0x00),
//                           child: Text('Backlight OFF'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Text('Sleep Time: ${sleepTime} min'),
//                       Spacer(),
//                       IconButton(
//                         onPressed: sleepTime > 1
//                             ? () {
//                           setState(() {
//                             sleepTime--;
//                           });
//                           _sendCommand(0x03, sleepTime, 0x00);
//                         }
//                             : null,
//                         icon: Icon(Icons.remove, color: Colors.white),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           setState(() {
//                             sleepTime++;
//                           });
//                           _sendCommand(0x03, sleepTime, 0x00);
//                         },
//                         icon: Icon(Icons.add, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _disconnect,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.redAccent,
//               foregroundColor: Colors.white,
//             ),
//             child: Text('Disconnect'),
//           ),
//         ],
//       ),
//     );
//   }
// }
