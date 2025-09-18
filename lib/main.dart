import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Slurvo/feature/splash/splash_screen.dart';
import 'core/di/injection_container.dart' as di;
import 'core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await di.init();

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
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

///
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// void main() {
//   runApp(const MyBleApp());
// }
//
// class MyBleApp extends StatefulWidget {
//   const MyBleApp({super.key});
//
//   @override
//   State<MyBleApp> createState() => _MyBleAppState();
// }
//
// class _MyBleAppState extends State<MyBleApp> {
//   final FlutterReactiveBle _ble = FlutterReactiveBle();
//   List<DiscoveredDevice> _devices = [];
//   DiscoveredDevice? _connectedDevice;
//   String _connectionStatus = "Disconnected";
//   bool _scanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     requestPermissions();
//   }
//
//   // Request required permissions
//   Future<void> requestPermissions() async {
//     final status = await [
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//       Permission.location,
//     ].request();
//
//     if (status[Permission.bluetoothScan] != PermissionStatus.granted ||
//         status[Permission.bluetoothConnect] != PermissionStatus.granted ||
//         status[Permission.location] != PermissionStatus.granted) {
//       // Show warning
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please grant all permissions to use BLE')),
//       );
//     }
//   }
//
//   // Start scanning
//   void _startScan() {
//     setState(() {
//       _devices.clear();
//       _scanning = true;
//     });
//
//     _ble.scanForDevices(withServices: []).listen((device) {
//       if (_devices.indexWhere((d) => d.id == device.id) == -1) {
//         setState(() {
//           _devices.add(device);
//         });
//       }
//     }, onError: (error) {
//       setState(() {
//         _scanning = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Scan error: $error")),
//       );
//     });
//   }
//
//   // Connect to selected device
//   void _connectToDevice(DiscoveredDevice device) {
//     setState(() {
//       _connectionStatus = "Connecting to ${device.name}...";
//     });
//
//     _ble.connectToDevice(
//       id: device.id,
//       connectionTimeout: const Duration(seconds: 5),
//     ).listen((connectionState) {
//       setState(() {
//         _connectionStatus = connectionState.connectionState.toString();
//         if (connectionState.connectionState == DeviceConnectionState.connected) {
//           _connectedDevice = device;
//         }
//       });
//     }, onError: (error) {
//       setState(() {
//         _connectionStatus = "Error: $error";
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text("Simple BLE App")),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               ElevatedButton(
//                 onPressed: _scanning ? null : _startScan,
//                 child: Text(_scanning ? "Scanning..." : "Start Scan"),
//               ),
//               const SizedBox(height: 10),
//               Text("Status: $_connectionStatus"),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _devices.length,
//                   itemBuilder: (context, index) {
//                     final device = _devices[index];
//                     return ListTile(
//                       title: Text(device.name.isNotEmpty ? device.name : "Unknown"),
//                       subtitle: Text(device.id),
//                       trailing: ElevatedButton(
//                         onPressed: () => _connectToDevice(device),
//                         child: const Text("Connect"),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               if (_connectedDevice != null) ...[
//                 const Divider(),
//                 Text("Connected to: ${_connectedDevice!.name}"),
//                 Text("Device ID: ${_connectedDevice!.id}"),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
