// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'dart:typed_data';
// import 'dart:async';
// import 'core/constants/app_colors.dart';
// import 'core/constants/app_images.dart';
// import 'core/constants/app_strings.dart';
// import 'feature/choose_club_screen/presentation/choose_club_screen_page.dart';
// import 'feature/home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
// import 'feature/home_screens/presentation/widgets/buttons/action_button.dart';
// import 'feature/home_screens/presentation/widgets/buttons/session_view_button.dart';
// import 'feature/home_screens/presentation/widgets/card/glassmorphism_card.dart';
// import 'feature/home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
// import 'feature/home_screens/presentation/widgets/custom_bar/custom_bar.dart';
// import 'feature/home_screens/presentation/widgets/header/header_row.dart';
//
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
//
//   List<DiscoveredService>? _services = [];
//   List<String>? _logs = [];
//
//   // Store found UUIDs globally
//   Uuid? _foundServiceId;
//   Uuid? _foundWriteCharId;
//   Uuid? _foundNotifyCharId;
//   bool? _useWriteWithResponse;
//
//   void _addLog(String message) {
//     final timestamp = DateTime.now().toIso8601String();
//     setState(() {
//       _logs?.add("[$timestamp] $message");
//     });
//     print(message);
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
//         // Clear stored UUIDs on disconnect
//         _foundServiceId = null;
//         _foundWriteCharId = null;
//         _foundNotifyCharId = null;
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
//   void _discoverServices(String deviceId) async {
//     try {
//       _services = await _ble.discoverServices(deviceId);
//       _addLog("Discovered ${_services?.length} services");
//
//       for (var service in _services??[]) {
//         _addLog("Service: ${service.serviceId}");
//
//         // Check if this is our service (using contains for short/long UUID match)
//         String serviceUuidStr = service.serviceId.toString().toLowerCase();
//         if (serviceUuidStr.contains("ffe0")) {
//           _foundServiceId = service.serviceId;
//           _addLog("  ✓ Found target service");
//         }
//
//         for (var c in service.characteristics) {
//           String props = "";
//           if (c.isReadable) props += "R ";
//           if (c.isWritableWithResponse) props += "W ";
//           if (c.isWritableWithoutResponse) props += "WNR ";
//           if (c.isNotifiable) props += "N ";
//           if (c.isIndicatable) props += "I ";
//           _addLog("  Char: ${c.characteristicId}, props: $props");
//
//           String charUuidStr = c.characteristicId.toString().toLowerCase();
//
//           // Check for notify characteristic
//           if (charUuidStr.contains("fee2") && c.isNotifiable) {
//             _foundNotifyCharId = c.characteristicId;
//             _addLog("    ✓ Found notify characteristic");
//
//           }
//
//           // Check for write characteristic
//           if (charUuidStr.contains("fee1") &&
//               (c.isWritableWithResponse || c.isWritableWithoutResponse)) {
//             _foundWriteCharId = c.characteristicId;
//             _useWriteWithResponse = c.isWritableWithResponse;
//             _addLog("    ✓ Found write characteristic (mode: ${c.isWritableWithResponse ? 'WITH response' : 'WITHOUT response'})");
//           }
//         }
//         setState(() {});
//       }
//
//       // Use found UUIDs or fall back to parsed ones
//       final actualServiceId = _foundServiceId ?? Uuid.parse(serviceUuid);
//       final actualNotifyCharId = _foundNotifyCharId ?? Uuid.parse(notifyCharacteristicUuid);
//
//       final characteristic = QualifiedCharacteristic(
//         serviceId: actualServiceId,
//         characteristicId: actualNotifyCharId,
//         deviceId: deviceId,
//       );
//
//       _addLog("Subscribing to notifications on ${actualNotifyCharId}");
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
//               setState(() {
//                 isLoading = false;
//                 _isPaused = false;
//               });
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
//               setState(() {
//                 units = !units;
//               });
//               print("[][][[]]4444444");
//               print("[][][[]]4444444");
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
//       }, onError: (error) {
//         _addLog('Characteristic subscription error: $error');
//         setState(() {
//           isLoading = false;
//         });
//       });
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
//   void _disconnect() {
//     _connectionSubscription?.cancel();
//     _characteristicSubscription?.cancel();
//     syncTimer?.cancel();
//     setState(() {
//       connectionState = DeviceConnectionState.disconnected;
//       connectedDevice = null;
//       _foundServiceId = null;
//       _foundWriteCharId = null;
//       _foundNotifyCharId = null;
//       _useWriteWithResponse = null;
//     });
//   }
//
//   void _startSyncTimer() {
//     syncTimer?.cancel();
//     syncTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if(_isPaused == true) print('pause1');
//       if (_isPaused != true) {
//         _sendSyncPacket();
//       }
//     });
//   }
//
//   void _sendSyncPacket() {
//     if(_isPaused) print('pause');
//     if (connectedDevice == null || connectionState != DeviceConnectionState.connected) return;
//     int clubId = golfData.clubName;
//     int checksum = (0x01 + clubId + 0x00) & 0xFF;
//
//     print("Club Number ${clubId}");
//     print("Sum ${checksum}");
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
//     setState(() {
//       isLoading = true;
//       _isPaused = true;
//     });
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
//   // Store the write mode
//   // bool? _useWriteWithResponse;
//
//   void _writeToCharacteristic(List<int> data) async {
//     if (connectedDevice == null) {
//       _addLog("✗ Cannot write: No connected device");
//       return;
//     }
//
//
//     if (_foundServiceId == null || _foundWriteCharId == null) {
//       _addLog("✗✗✗ NO WRITABLE CHARACTERISTIC FOUND!");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No writable characteristic found')),
//       );
//       return;
//     }
//
//     try {
//       final characteristic = QualifiedCharacteristic(
//         serviceId: _foundServiceId!,
//         characteristicId: _foundWriteCharId!,
//         deviceId: connectedDevice!.id,
//       );
//
//       _addLog("Write -> ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
//       print('Writing to ${_foundWriteCharId}');
//       print('Data ${data}');
//
//       // Use the correct write method based on characteristic properties
//       if (_useWriteWithResponse == true) {
//         _addLog("Using writeCharacteristicWithResponse");
//         await _ble.writeCharacteristicWithResponse(
//           characteristic,
//           value: data,
//         );
//       } else {
//         _addLog("Using writeCharacteristicWithoutResponse");
//         await _ble.writeCharacteristicWithoutResponse(
//           characteristic,
//           value: data,
//         );
//       }
//       _addLog("✓ Write successful");
//     } catch (e) {
//       _addLog('✗ Write error: $e');
//       // Reset cached values so they can be rediscovered
//       _foundWriteCharId = null;
//       _foundServiceId = null;
//       _useWriteWithResponse = null;
//     }
//   }
//
//   void _parseGolfData(Uint8List data) {
//     if (data.length < 15 || data[0] != 0x47 || data[1] != 0x46) return;
//     setState(() {
//       golfData.battery = data[3];
//
//       batteryNotifier.value = golfData.battery;
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
//     return connectionState == DeviceConnectionState.connected
//         ? Scaffold(
//         backgroundColor: AppColors.primaryBackground,
//         bottomNavigationBar: const BottomNavBar(),
//         appBar: CustomAppBar(connectedDevice: connectedDevice, showSettingButton: true,services: _services,),
//         body: _buildConnectedView()
//     )
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
//                   final device = devices[index];
//                   return Card(
//                     margin: EdgeInsets.symmetric(
//                         horizontal: w * 0.04, vertical: w * 0.01),
//                     color: Colors.grey[900],
//                     child: ListTile(
//                       leading: Icon(
//                         Icons.bluetooth,
//                         color: _getSignalColor(device.rssi),
//                         size: w * 0.06,
//                       ),
//                       title: Text(
//                         device.name.isNotEmpty
//                             ? device.name
//                             : "Unknown Device",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       subtitle: Text(
//                         "ID: ${device.id}\nSignal: ${device.rssi} dBm ${_getSignalStrength(device.rssi)}",
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
//                     selectedClub: Club(code: golfData.clubName.toString(), name: clubs[golfData.clubName]),
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
//                 isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,)):
//                 Expanded(
//                   child: _golfMetrics.isEmpty
//                       ? const Center(
//                     child: Text(
//                       "No shot data received yet",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   )
//                       : GridView.builder(
//                     padding: const EdgeInsets.all(16),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
//                         onPressed: (){},
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
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class GolfData {
  int battery = 0;
  int recordNumber = 0;
  int clubName = 0;
  double clubSpeed = 0.0;
  double ballSpeed = 0.0;
  double carryDistance = 0.0;
  double totalDistance = 0.0;

  double get smashFactor => clubSpeed > 0 ? ballSpeed / clubSpeed : 0.0;
}

class GolfDeviceScreen extends StatefulWidget {
  @override
  _GolfDeviceScreenState createState() => _GolfDeviceScreenState();
}

class _GolfDeviceScreenState extends State<GolfDeviceScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _notifySub;

  List<DiscoveredDevice> devices = [];
  bool isScanning = false;
  bool isConnecting = false;
  bool isLoading = false;
  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;
  DiscoveredDevice? connectedDevice;

  Timer? syncTimer;
  GolfData golfData = GolfData();
  bool _hasWrittenInitialSync = false;
  bool units = false; // false = Yards, true = Meters

  List<DiscoveredService>? _services;
  Uuid? _serviceId;
  Uuid? _writeCharId;
  Uuid? _notifyCharId;
  bool? _useWriteWithResponse;

  @override
  void initState() {
    super.initState();
    _ble.statusStream.listen((status) {
      if (status == BleStatus.ready) _scanForDevices();
    });
  }

  @override
  void dispose() {
    syncTimer?.cancel();
    _scanSub?.cancel();
    _connectionSub?.cancel();
    _notifySub?.cancel();
    super.dispose();
  }

  void _scanForDevices() {
    if (isScanning) return;
    setState(() {
      isScanning = true;
      devices.clear();
    });

    _scanSub?.cancel();
    _scanSub = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: false,
    ).listen((device) {
      if (device.name.isNotEmpty && (device.name.startsWith("A-1LM-") || device.name.contains("BM"))) {
        final index = devices.indexWhere((d) => d.id == device.id);
        setState(() {
          if (index >= 0) {
            devices[index] = device;
          } else {
            devices.add(device);
          }
        });
      }
    });

    Timer(Duration(seconds: 10), () {
      _scanSub?.cancel();
      setState(() => isScanning = false);
    });
  }

  void _connectToDevice(DiscoveredDevice device) async {
    if (isConnecting) return;
    setState(() => isConnecting = true);

    _connectionSub?.cancel();
    _connectionSub = _ble.connectToDevice(
      id: device.id,
      connectionTimeout: Duration(seconds: 10),
    ).listen((update) {
      setState(() => connectionState = update.connectionState);

      if (update.connectionState == DeviceConnectionState.connected) {
        setState(() {
          isConnecting = false;
          connectedDevice = device;
          _hasWrittenInitialSync = false;
        });
        _discoverServices(device.id);
        _startSyncTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${device.name}')),
        );
      } else if (update.connectionState == DeviceConnectionState.disconnected) {
        setState(() {
          isConnecting = false;
          connectedDevice = null;
          _hasWrittenInitialSync = false;
        });
        _notifySub?.cancel();
        syncTimer?.cancel();
        _serviceId = _writeCharId = _notifyCharId = null;
      }
    }, onError: (error) {
      setState(() {
        isConnecting = false;
        connectionState = DeviceConnectionState.disconnected;
      });
    });
  }

  void _discoverServices(String deviceId) async {
    try {
      _services = await _ble.discoverServices(deviceId);

      for (var service in _services ?? []) {
        if (service.serviceId.toString().toLowerCase().contains("ffe0")) {
          _serviceId = service.serviceId;

          for (var c in service.characteristics) {
            String charId = c.characteristicId.toString().toLowerCase();

            if (charId.contains("fee2") && c.isNotifiable) {
              _notifyCharId = c.characteristicId;
            }

            if (charId.contains("fee1") && (c.isWritableWithResponse || c.isWritableWithoutResponse)) {
              _writeCharId = c.characteristicId;
              _useWriteWithResponse = c.isWritableWithResponse;
            }
          }
        }
      }

      if (_serviceId != null && _notifyCharId != null) {
        _notifySub = _ble.subscribeToCharacteristic(
          QualifiedCharacteristic(
            serviceId: _serviceId!,
            characteristicId: _notifyCharId!,
            deviceId: deviceId,
          ),
        ).listen((data) {

          print("{{{{");
          print(data);
          if (data.length >= 3) {
            switch (data[2]) {
              case 0x01:
                if (data.length >= 16) _parseGolfData(Uint8List.fromList(data));
                break;
              case 0x02:
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Club updated")),
                );
                break;
              case 0x04:
              // Unit change response - reload preference and refresh UI
                setState(() {
                  units = !units;
                });
                break;
            }
          }
        });
      }
    } catch (e) {
      print('Service discovery error: $e');
    }
  }

  void _startSyncTimer() {
    syncTimer?.cancel();
    syncTimer = Timer.periodic(Duration(seconds: 10), (_) {
      if (!isLoading) _sendSyncPacket();
    });
  }

  void _sendSyncPacket() {
    if (connectedDevice == null || _writeCharId == null) return;

    int clubId = golfData.clubName;
    int checksum = (0x01 + clubId) & 0xFF;

    _writeData([0x47, 0x46, 0x01, clubId, 0x00, checksum]);
  }

  void sendCommand(int cmd, int param1, int param2) {
    if (connectedDevice == null || _writeCharId == null) return;

    if (cmd == 0x02) {
      setState(() => isLoading = true);
    }

    List<int> packet = [0x47, 0x46, cmd, param1, param2];
    int checksum = packet.skip(2).fold(0, (sum, byte) => sum + byte) & 0xFF;
    packet.add(checksum);

    _writeData(packet);
  }

  void _writeData(List<int> data) async {
    if (_serviceId == null || _writeCharId == null || connectedDevice == null) return;

    try {
      final char = QualifiedCharacteristic(
        serviceId: _serviceId!,
        characteristicId: _writeCharId!,
        deviceId: connectedDevice!.id,
      );

      if (_useWriteWithResponse == true) {
        await _ble.writeCharacteristicWithResponse(char, value: data);
      } else {
        await _ble.writeCharacteristicWithoutResponse(char, value: data);
      }
    } catch (e) {
      print('Write error: $e');
    }
  }

  void _parseGolfData(Uint8List data) {
    if (data[0] != 0x47 || data[1] != 0x46) return;

    setState(() {
      golfData.battery = data[3];
      // batteryNotifier.value = golfData.battery;
      golfData.recordNumber = (data[4] << 8) | data[5];
      golfData.clubName = data[6];
      golfData.clubSpeed = ((data[7] << 8) | data[8]) / 10.0;
      golfData.ballSpeed = ((data[9] << 8) | data[10]) / 10.0;
      golfData.carryDistance = ((data[11] << 8) | data[12]) / 10.0;
      golfData.totalDistance = ((data[13] << 8) | data[14]) / 10.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (connectionState == DeviceConnectionState.connected &&
        !_hasWrittenInitialSync &&
        _writeCharId != null) {
      _hasWrittenInitialSync = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendSyncPacket());
    }

    return connectionState == DeviceConnectionState.connected
        ? Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: BottomNavBar(),
      // appBar: CustomAppBar(
      //   // connectedDevice: connectedDevice,
      //   showSettingButton: true,
      //   services: _services,
      //   selectedUnit: units,
      // ),
      body: _buildConnectedView(),
    )
        : _buildScanScreen();
  }

  Widget _buildScanScreen() {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Scanned Devices", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [IconButton(onPressed: _scanForDevices, icon: Icon(Icons.refresh))],
      ),
      body: isScanning || isConnecting
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : devices.isEmpty
          ? Center(child: Text("No devices found", style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: Icon(Icons.bluetooth, color: Colors.green),
              title: Text(device.name, style: TextStyle(color: Colors.white)),
              subtitle: Text("Signal: ${device.rssi} dBm", style: TextStyle(color: Colors.white70)),
              onTap: () => _connectToDevice(device),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectedView() {
    return Column(
      children: [
        Divider(thickness: 1, color: AppColors.dividerColor),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: HeaderRow(
                    showClubName: true,
                    goScanScreen: true,
                    headingName: "Shot Analysis",
                    selectedClub: Club(
                      code: golfData.clubName.toString(),
                      name: _clubs[golfData.clubName],
                    ),
                    onClubSelected: (value) {
                      setState(() => golfData.clubName = int.parse(value.code));
                      sendCommand(0x02, int.parse(value.code), 0x00);
                    },
                  ),
                ),
                SizedBox(height: 14),
                CustomizeBar(),
                SizedBox(height: 15),
                isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.42,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final metrics = [
                        {"metric": "Club Speed", "value": golfData.clubSpeed.toStringAsFixed(1), "unit": "MPH"},
                        {"metric": "Ball Speed", "value": golfData.ballSpeed.toStringAsFixed(1), "unit": "MPH"},
                        {"metric": "Carry Distance", "value": golfData.carryDistance.toStringAsFixed(1), "unit": units ? "M" : "YDS"},
                        {"metric": "Total Distance", "value": golfData.totalDistance.toStringAsFixed(1), "unit": units ? "M" : "YDS"},
                        {"metric": "Smash Factor", "value": golfData.smashFactor.toStringAsFixed(2), "unit": ""},
                        {"metric": "Shot Number", "value": golfData.recordNumber.toStringAsFixed(2), "unit": ""},
                      ];
                      return GlassmorphismCard(
                        value: metrics[index]["value"]!,
                        name: metrics[index]["metric"]!,
                        unit: metrics[index]["unit"]!,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ActionButton(
                        text: AppStrings.deleteShotText,
                        onPressed: () {},
                      ),
                      ActionButton(
                        svgAssetPath: AppImages.groupIcon,
                        text: AppStrings.dispersionText,
                        onPressed: (){},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                SessionViewButton(onSessionClick: () {  },),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const List<String> _clubs = [
    "1W", "2W", "3W", "5W", "7W", "2H", "3H", "4H", "5H",
    "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
    "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
  ];
}