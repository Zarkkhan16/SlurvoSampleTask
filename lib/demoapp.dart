
import 'package:onegolf/feature/choose_club_screen/presentation/choose_club_screen_page.dart';
import 'package:onegolf/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:async';

import 'core/constants/app_colors.dart';
import 'core/constants/app_images.dart';
import 'core/constants/app_strings.dart';
import 'feature/home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import 'feature/home_screens/presentation/widgets/buttons/action_button.dart';
import 'feature/home_screens/presentation/widgets/buttons/session_view_button.dart';
import 'feature/home_screens/presentation/widgets/card/glassmorphism_card.dart';
import 'feature/home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import 'feature/home_screens/presentation/widgets/custom_bar/custom_bar.dart';
import 'feature/home_screens/presentation/widgets/header/header_row.dart';

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

class GolfData {
  int battery = 0;            // BYTE 4 (doc) = data[3]
  int recordNumber = 0;       // BYTE 5-6 (doc) = data[4], data[5]
  int clubName = 0;           // BYTE 7 (doc) = data[6]
  double clubSpeed = 0.0;     // BYTE 8-9 (doc) = data[7], data[8]
  double ballSpeed = 0.0;     // BYTE 10-11 (doc) = data[9], data[10]
  double carryDistance = 0.0; // BYTE 12-13 (doc) = data[11], data[12]
  double totalDistance = 0.0; // BYTE 14-15 (doc) = data[13], data[14]

  double get smashFactor => clubSpeed > 0 ? ballSpeed / clubSpeed : 0.0;

  String get batteryStatus {
    switch (battery) {
      case 0: return "Blank";
      case 1: return "Low";
      case 2: return "Middle";
      case 3: return "Full";
      default: return "Unknown";
    }
  }

  IconData get batteryIcon {
    switch (battery) {
      case 0: return Icons.battery_0_bar;
      case 1: return Icons.battery_2_bar;
      case 2: return Icons.battery_4_bar;
      case 3: return Icons.battery_full;
      default: return Icons.battery_unknown;
    }
  }

  Color get batteryColor {
    switch (battery) {
      case 0: return Colors.grey;        // blank
      case 1: return Colors.redAccent;   // low
      case 2: return Colors.orangeAccent;// middle
      case 3: return Colors.greenAccent; // full
      default: return Colors.white;
    }
  }

  String get clubNameString {
    const clubs = [
      "1W", "2W", "3W", "5W", "7W", "2H", "3H", "4H", "5H",
      "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
      "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
    ];
    return clubName <= clubs.length ? clubs[clubName] : "Unknown";
  }

  String get clubLoftString {
    const clubLofts = [
      10, 13, 15, 17, 21,
      17, 19, 21, 24,
      14, 18, 21, 23, 26, 29, 33, 37, 41,
      46, 50, 52, 54, 56, 58, 60
    ];

    if (clubName >= 0 && clubName < clubLofts.length) {
      return clubLofts[clubName].toString(); // return as String
    } else {
      return "Unknown";
    }

  }
}

class GolfDeviceScreen extends StatefulWidget {
  @override
  _GolfDeviceScreenState createState() => _GolfDeviceScreenState();
}

class _GolfDeviceScreenState extends State<GolfDeviceScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;

  List<DiscoveredDevice> devices = [];
  bool isScanning = false;
  bool isConnecting = false;
  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;
  DiscoveredDevice? connectedDevice;

  Timer? syncTimer;
  GolfData golfData = GolfData();
  int sleepTime = 1;
  bool units = false;

  int? selectedClub;

  static const String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String writeCharacteristicUuid = "0000fee1-0000-1000-8000-00805f9b34fb";
  static const String notifyCharacteristicUuid = "0000fee2-0000-1000-8000-00805f9b34fb";

  @override
  void initState() {
    super.initState();
    _checkBleStatus();
  }

  @override
  void dispose() {
    syncTimer?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _characteristicSubscription?.cancel();
    super.dispose();
  }

  void _checkBleStatus() async {
    _ble.statusStream.listen((status) {
      print('BLE Status: $status');
      _addLog('BLE Status: $status');

      if (status == BleStatus.ready) {
        _scanForDevices();
      }
    });
  }
  List<DiscoveredService>? _services = [];
  List<String>? _logs = [];

  void _addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    setState(() {
      _logs?.add("[$timestamp] $message");
    });
    print(message); // still goes to console
  }

  void _scanForDevices() {
    if (isScanning) return;
    setState(() {
      isScanning = true;
      devices.clear();
    });

    _scanSubscription?.cancel();
    _scanSubscription = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: false,
    ).listen((device) {
      if (device.name.isNotEmpty && (device.name.startsWith("A-1LM-")||device.name.contains("BM"))) {
        final existingIndex = devices.indexWhere((d) => d.id == device.id);
        setState(() {
          if (existingIndex >= 0) {
            devices[existingIndex] = device;
          } else {
            devices.add(device);
          }
        });
      }
    }, onError: (error) {
      print('Scan error: $error');
    });

    Timer(Duration(seconds: 10), () {
      _stopScanning();
    });
  }

  void _stopScanning() {
    _scanSubscription?.cancel();
    setState(() {
      isScanning = false;
    });
  }

  void _connectToDevice(DiscoveredDevice device) async {
    if (isConnecting) return;
    setState(() {
      isConnecting = true;
    });

    _connectionSubscription?.cancel();
    _connectionSubscription = _ble.connectToDevice(
      id: device.id,
      connectionTimeout: Duration(seconds: 10),
    ).listen((connectionStateUpdate) {
      setState(() {
        connectionState = connectionStateUpdate.connectionState;
      });

      if (connectionStateUpdate.connectionState == DeviceConnectionState.connected) {
        setState(() {
          isConnecting = false;
          connectedDevice = device;
        });

        _discoverServices(device.id);
        _startSyncTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${device.name}')),
        );
      } else if (connectionStateUpdate.connectionState == DeviceConnectionState.disconnected) {
        setState(() {
          isConnecting = false;
          connectedDevice = null;
        });
        _characteristicSubscription?.cancel();
        syncTimer?.cancel();
      }
    }, onError: (error) {
      setState(() {
        isConnecting = false;
        connectionState = DeviceConnectionState.disconnected;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $error')),
      );
    });
  }

  ///v2
  void _discoverServices(String deviceId) async {
    try {
      _services = await _ble.discoverServices(deviceId);
      _addLog("Discovered ${_services?.length} services");
      for (var service in _services??[]) {
        _addLog("Service: ${service.serviceId}");
        for (var c in service.characteristics) {
          _addLog("  Char: ${c.characteristicId}, props: ${c.isReadable ? "R" : ""}${c.isWritableWithoutResponse ? " W" : ""}${c.isNotifiable ? " N" : ""}");
        }
        setState(() {});
      }

      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(notifyCharacteristicUuid),
        deviceId: deviceId,
      );

      _characteristicSubscription = _ble.subscribeToCharacteristic(characteristic).listen((data) {

        print('Data From Device ${data}');
        if (data.isNotEmpty) {
          _addLog("Notify <- ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
        }

        if (data.length >= 3) {
          final cmd = data[2];

          switch (cmd) {
            case 0x01: // Sync data (golf stats)
              if (data.length >= 16) {
                _parseGolfData(Uint8List.fromList(data));
              }
              break;

            case 0x02: // Club name update

              setState(() {
                isLoading = false;
                _isPaused = false;
              });
              // _resumeSyncTimer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Club name updated"),
                  duration: Duration(seconds: 2),
                ),
              );
              break;

            case 0x03: // Sleep timer set
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("⏳ Sleep timer set"),
                  duration: Duration(seconds: 2),
                ),
              );
              break;

            case 0x04: // Unit change
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("📏 Unit updated"),
                  duration: Duration(seconds: 2),
                ),
              );
              break;

            case 0x06: // Backlight ON/OFF
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("💡 Backlight updated"),
                  duration: Duration(seconds: 2),
                ),
              );
              break;

            default:
              print("Unknown CMD: $cmd");
          }
        }
        // if (data.length >= 16) {
        //   // final testPacket = [
        //   //   0x47, 0x46, 0x01, 0x01, 0x00, 0x1E, 0x00,
        //   //   0x04, 0x8A, 0x06, 0x9F, 0x0B, 0x36, 0x0B, 0xF0, 0x7F
        //   // ];
        //   // _parseGolfData(Uint8List.fromList([71, 70, 1, 1, 0, 30, 4, 4, 138, 6, 159, 11, 54, 11, 240, 127]));
        //   _parseGolfData(Uint8List.fromList(data));
        // }
      }, onError: (error) {
        _addLog('Characteristic subscription error: $error');
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _addLog('Error discovering services: $e');
    }
  }
  bool isLoading = false;
  bool _isPaused = false;
  void _disconnect() {
    _connectionSubscription?.cancel();
    _characteristicSubscription?.cancel();
    syncTimer?.cancel();
    setState(() {
      connectionState = DeviceConnectionState.disconnected;
      connectedDevice = null;
    });
  }

  void _startSyncTimer() {
    syncTimer?.cancel();
    syncTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(_isPaused == true) print('pause1');
      if (_isPaused != true) {        // only send if not paused
        _sendSyncPacket();
      }
    });
  }

  void _pauseSyncTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeSyncTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  void _sendSyncPacket() {
    if(_isPaused) print('pause');
    if (connectedDevice == null || connectionState != DeviceConnectionState.connected) return;
    int clubId = golfData.clubName; // <-- your current club index
    int checksum = (0x01 + clubId + 0x00) & 0xFF; // sum of bytes 3~5

    print("Club Number ${clubId}");
    print("Sum ${checksum}");

    // List<int> syncPacket = [0x47, 0x46, 0x01, 0x00, 0x00, 0x01];

    List<int> syncPacket = [
      0x47, 0x46,       // Header "GF"
      0x01,             // CMD = sync
      clubId,           // current club id
      0x00,             // reserved
      checksum,         // checksum
    ];
    _writeToCharacteristic(syncPacket);
  }

  void _sendCommand(int cmd, int param1, int param2) {
    if (connectedDevice == null || connectionState != DeviceConnectionState.connected) return;

    // _pauseSyncTimer();  // ⏸ stop sync packets while command is in progress
    setState(() {
      isLoading = true;
      _isPaused = true;
    });
    List<int> packet = [0x47, 0x46, cmd, param1, param2];
    int checksum = 0;
    for (int i = 2; i < packet.length; i++) {
      checksum += packet[i];
    }
    packet.add(checksum & 0xFF);

    print('?????????');
    print(packet);
    _writeToCharacteristic(packet);
  }

  void _writeToCharacteristic(List<int> data) async {
    if (connectedDevice == null) return;
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(writeCharacteristicUuid),
        deviceId: connectedDevice!.id,
      );

      _addLog("Write -> ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");

      print('Data ${data}');

      await _ble.writeCharacteristicWithoutResponse(
        characteristic,
        value: data,
      );
    } catch (e) {
      _addLog('Write error: $e');
    }
  }
///v2
  void _parseGolfData(Uint8List data) {

    if (data.length < 15 || data[0] != 0x47 || data[1] != 0x46) return;
    setState(() {
      golfData.battery = data[3];                           // BYTE 4

      // Record number = little endian
      golfData.recordNumber = (data[4] << 8) | data[5];

      golfData.clubName = data[6];                         // BYTE 7

      // Club/ball speed, distances = big endian
      golfData.clubSpeed = (((data[7] << 8) | data[8]) / 10.0);
      golfData.ballSpeed = (((data[9] << 8) | data[10]) / 10.0);
      golfData.carryDistance = (((data[11] << 8) | data[12]) / 10.0);
      golfData.totalDistance = (((data[13] << 8) | data[14]) / 10.0);
    });


  }
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return
      connectionState == DeviceConnectionState.connected
?
      Scaffold(
        backgroundColor: AppColors.primaryBackground,
        bottomNavigationBar: const BottomNavBar(),
        appBar: const CustomAppBar(),
        body: _buildConnectedView()
      ) :

      Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Scanned Devices",
          style: TextStyle(
              fontSize: w * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _scanForDevices,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Container(
        color: Colors.black,
        child: isScanning || isConnecting
            ? _centerMessage(
          w,
          isConnecting ? "Connecting..." : "Scanning for devices...",
          showLoader: true,
        )
            : devices.isEmpty
            ? _centerMessage(w, "No devices found", showRetry: true)
            : connectionState == DeviceConnectionState.connected ? _buildConnectedView() : Column(
          children: [
            Padding(
              padding: EdgeInsets.all(w * 0.04),
              child: Text(
                "Found ${devices.length} device${devices.length == 1 ? '' : 's'}",
                style: TextStyle(
                    color: Colors.white70, fontSize: w * 0.035),
              ),
            ),
            Expanded(
              child: devices.isEmpty
                  ? const Center(
                child: Text(
                  "No devices found",
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: w * 0.04, vertical: w * 0.01),
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: Icon(
                        Icons.bluetooth,
                        color: _getSignalColor(device.rssi),
                        size: w * 0.06,
                      ),
                      title: Text(
                        device.name.isNotEmpty
                            ? device.name
                            : "Unknown Device",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        "ID: ${device.id}\nSignal: ${device.rssi} dBm ${_getSignalStrength(device.rssi)}",
                        style: const TextStyle(
                            color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 16,
                      ),
                      onTap: () => _connectToDevice(device),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _centerMessage(double w, String message,
      {bool showLoader = false, bool showRetry = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLoader) const CircularProgressIndicator(color: Colors.white),
          SizedBox(height: w * 0.04),
          Text(message,
              style: TextStyle(color: Colors.white, fontSize: w * 0.045),
              textAlign: TextAlign.center),
          if (showRetry)
            Padding(
              padding: EdgeInsets.only(top: w * 0.04),
              child: ElevatedButton(
                onPressed: _scanForDevices,
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

  String _getSignalStrength(int rssi) => rssi >= -50
      ? "(Excellent)"
      : rssi >= -70
      ? "(Good)"
      : "(Weak)";

  static const List<String> clubs = [
    "1W", "2W", "3W", "5W", "7W",
    "2H", "3H", "4H", "5H",
    "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
    "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
  ];
///v1
  Widget _buildConnectedView() {
    return Column(
      children: [
        const Divider(thickness: 1, color: AppColors.dividerColor),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 60,
                  child: HeaderRow(
                    showClubName: true,
                    headingName: "Shot Analysis",
                    selectedClub: Club(code: golfData.clubName.toString(), name: clubs[golfData.clubName]), // use the index
                    onClubSelected: (value) {
                      setState(() {
                        golfData.clubName = int.parse(value.code); // update golfData when changed
                        isLoading = true;
                      });
                      _sendCommand(0x02, int.parse(value.code), 0x00); // notify device
                    },
                  ),
                ),
                const SizedBox(height: 14),
                const CustomizeBar(),
                const SizedBox(height: 15),
                isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,)):
                Expanded(
                  child: _golfMetrics.isEmpty
                      ? const Center(
                    child: Text(
                      "No shot data received yet",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.42,
                    ),
                    itemCount: _golfMetrics.length,
                    itemBuilder: (context, index) {
                      final shot = _golfMetrics[index];
                      return GlassmorphismCard(
                        value: shot["value"]!,
                        name: shot["metric"]!,
                        unit: shot["unit"]!,
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
                        onPressed: (){}, // Example write
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                const SessionViewButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );




      SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text("Club: "),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButton<int>(
                  value: golfData.clubName, // current club
                  isExpanded: true,
                  items: List.generate(
                    clubs.length,
                        (index) => DropdownMenuItem(
                      value: index,
                      child: Text(clubs[index]),
                    ),
                  ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedClub = value;
                          golfData.clubName = value; // keep UI consistent
                        });
                        _sendCommand(0x02, value, 0x00);
                      }
                    },
                ),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          golfData.batteryIcon,
                          color: golfData.batteryColor,
                          size: 32,
                        ),
                        Text(golfData.batteryStatus),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.golf_course, size: 32, color: Colors.greenAccent),
                        Text("${golfData.clubNameString} (${golfData.clubLoftString})"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.numbers, size: 32, color: Colors.blueAccent),
                        Text('Shot #${golfData.recordNumber}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.speed, size: 40, color: Colors.blueAccent),
                        SizedBox(height: 8),
                        Text(
                          '${golfData.clubSpeed.toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text('Club Speed (MPH)'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.sports_baseball, size: 40, color: Colors.orangeAccent),
                        SizedBox(height: 8),
                        Text(
                          '${golfData.ballSpeed.toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text('Ball Speed (MPH)'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.flag, size: 40, color: Colors.greenAccent),
                        SizedBox(height: 8),
                        Text(
                          '${golfData.carryDistance.toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text('Carry Distance (${units ? "m" : "yds"})'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.golf_course, size: 40, color: Colors.purpleAccent),
                        SizedBox(height: 8),
                        Text(
                          '${golfData.totalDistance.toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text('Total Distance (${units ? "m" : "yds"})'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.insights, size: 40, color: Colors.amberAccent),
                  SizedBox(height: 8),
                  Text(
                    '${golfData.smashFactor.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text('Smash Factor'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              units = !units;
                            });
                            _sendCommand(0x04, units ? 1 : 0, 0x00);
                          },
                          child: Text(units ? 'Switch to Yards' : 'Switch to Meters'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _sendCommand(0x05, 0x00, 0x00);
                          },
                          child: Text('Clear Records'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _sendCommand(0x06, 1, 0x00),
                          child: Text('Backlight ON'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _sendCommand(0x06, 0, 0x00),
                          child: Text('Backlight OFF'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Sleep Time: ${sleepTime} min'),
                      Spacer(),
                      IconButton(
                        onPressed: sleepTime > 1
                            ? () {
                          setState(() {
                            sleepTime--;
                          });
                          _sendCommand(0x03, sleepTime, 0x00);
                        }
                            : null,
                        icon: Icon(Icons.remove, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            sleepTime++;
                          });
                          _sendCommand(0x03, sleepTime, 0x00);
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _disconnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> get _golfMetrics {
    return [
      {
        "metric": "Club Speed",
        "value": golfData.clubSpeed.toStringAsFixed(1),
        "unit": "MPH",
      },
      {
        "metric": "Ball Speed",
        "value": golfData.ballSpeed.toStringAsFixed(1),
        "unit": "MPH",
      },
      {
        "metric": "Carry Distance",
        "value": golfData.carryDistance.toStringAsFixed(1),
        "unit": units ? "M" : "YDS",
      },
      {
        "metric": "Total Distance",
        "value": golfData.totalDistance.toStringAsFixed(1),
        "unit": units ? "M" : "YDS",
      },
      {
        "metric": "Smash Factor",
        "value": golfData.smashFactor.toStringAsFixed(2),
        "unit": "",
      },
    ];
  }
}