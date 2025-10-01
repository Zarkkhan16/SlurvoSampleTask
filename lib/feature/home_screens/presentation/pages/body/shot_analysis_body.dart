// import 'package:flutter/material.dart';
// import 'package:Slurvo/core/constants/app_colors.dart';
// import 'package:Slurvo/core/constants/app_images.dart';
// import 'package:Slurvo/core/constants/app_strings.dart';
// import 'package:Slurvo/feature/home_screens/presentation/widgets/buttons/action_button.dart';
// import 'package:Slurvo/feature/home_screens/presentation/widgets/buttons/session_view_button.dart';
// import 'package:Slurvo/feature/home_screens/presentation/widgets/custom_bar/custom_bar.dart';
// import 'package:Slurvo/feature/home_screens/presentation/widgets/grid/shot_grid_view.dart';
// import 'package:Slurvo/feature/home_screens/presentation/widgets/header/header_row.dart';
//
// import '../../../../choose_club_screen/presentation/choose_club_screen_page.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// class ShotAnalysisBody extends StatefulWidget {
//   DiscoveredDevice? connectedDevice;
//   ShotAnalysisBody({super.key, required this.connectedDevice});
//
//   @override
//   State<ShotAnalysisBody> createState() => _ShotAnalysisBodyState();
// }
//
// class _ShotAnalysisBodyState extends State<ShotAnalysisBody> {
//   Club? mySelectedClub;
//   @override
//   Widget build(BuildContext context) {
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
//                     headingName: "Shot Analysis",
//                     selectedClub: mySelectedClub,
//                     onClubSelected: (club) {
//                       setState(() {
//                         mySelectedClub = club;
//                       });
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 14),
//                 CustomizeBar(),
//                 SizedBox(height: 15),
//                 Expanded(child: ShotGridView()),
//                 SizedBox(height: 10),
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
//                 SizedBox(height: 17),
//                 SessionViewButton(),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:Slurvo/core/constants/app_strings.dart';
import 'package:Slurvo/feature/home_screens/domain/entities/shot_data.dart';
import 'package:Slurvo/feature/home_screens/domain/entities/shot_parser.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/card/glassmorphism_card.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/header/header_row.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/buttons/action_button.dart';
import 'package:Slurvo/core/constants/app_images.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/buttons/session_view_button.dart';
import 'package:Slurvo/feature/home_screens/presentation/widgets/custom_bar/custom_bar.dart';

class ShotAnalysisBody extends StatefulWidget {
  final DiscoveredDevice? connectedDevice;
  const ShotAnalysisBody({super.key, required this.connectedDevice});

  @override
  State<ShotAnalysisBody> createState() => _ShotAnalysisBodyState();
}

class _ShotAnalysisBodyState extends State<ShotAnalysisBody> {
  final flutterReactiveBle = FlutterReactiveBle();

  StreamSubscription<ConnectionStateUpdate>? _connection;
  QualifiedCharacteristic? _characteristic;
  List<ShotDataNew> _shots = [];

  String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  String writeCharacteristicUuid = "0000fee1-0000-1000-8000-00805f9b34fb";
  String notifyCharacteristicUuid = "0000fee2-0000-1000-8000-00805f9b34fb";
  Timer? syncTimer;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  List<DiscoveredService>? _services = [];
  StreamSubscription<List<int>>? characteristicSubscription;

  void _discoverServices(String deviceId) async {
    try {
      _services = await flutterReactiveBle.discoverServices(deviceId);
      // _addLog("Discovered ${_services?.length} services");
      for (var service in _services ?? []) {
        // _addLog("Service: ${service.serviceId}");
        for (var c in service.characteristics) {
          // _addLog("  Char: ${c.characteristicId}, props: ${c.isReadable ? "R" : ""}${c.isWritableWithoutResponse ? " W" : ""}${c.isNotifiable ? " N" : ""}");
        }
        setState(() {});
      }

      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(notifyCharacteristicUuid),
        deviceId: deviceId,
      );

      characteristicSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristic)
          .listen((data) {
        print('Data From Device ${data}');
        if (data.isNotEmpty) {
          // _addLog("Notify <- ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
        }

        if (data.length >= 3) {
          final cmd = data[2];

          switch (cmd) {
            case 0x01: // Sync data (golf stats)
              if (data.length >= 16) {
                print('data ??????');
                print(data);
                // _parseGolfData(Uint8List.fromList(data));
              }
              break;

            case 0x02: // Club name update
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Club name updated"),
                  duration: Duration(seconds: 2),
                ),
              );
              break;

            case 0x03: // Sleep timer set
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("⏳ Sleep timer set"),
                  duration: Duration(seconds: 2),
                ),
              );
              break;

            case 0x04: // Unit change
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("📏 Unit updated"),
                  duration: Duration(seconds: 2),
                ),
              );
              break;

            case 0x06: // Backlight ON/OFF
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("💡 Backlight updated"),
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
        // _addLog('Characteristic subscription error: $error');
      });
    } catch (e) {
      // _addLog('Error discovering services: $e');
    }
  }
  void _startSyncTimer() {
    syncTimer?.cancel();
    syncTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _sendSyncPacket();
    });
  }

  void _sendSyncPacket() {
    if (widget.connectedDevice == null) return;
    int clubId = 01; // <-- your current club index
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
    if (widget.connectedDevice == null) return;

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
    if (widget.connectedDevice == null) return;
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(writeCharacteristicUuid),
        deviceId: widget.connectedDevice!.id,
      );

      // _addLog("Write -> ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");

      print('Data ${data}');

      await flutterReactiveBle.writeCharacteristicWithoutResponse(
        characteristic,
        value: data,
      );
    } catch (e) {
      // _addLog('Write error: $e');
    }
  }



    void _connectToDevice() {
    _connection?.cancel();
    _connection = flutterReactiveBle.connectToDevice(
      id: widget.connectedDevice!.id,
      connectionTimeout: const Duration(seconds: 10),
    ).listen((connectionState) async {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        debugPrint("✅ Connected to ${widget.connectedDevice?.name}");
        _discoverServices(widget.connectedDevice!.id);
        _startSyncTimer();
      }
    }, onError: (e) {
      debugPrint("❌ Connection error: $e");
    });
  }

  @override
  void dispose() {
    _connection?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(thickness: 1, color: AppColors.dividerColor),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(
                //   height: 60,
                //   child: HeaderRow(
                //     showClubName: true,
                //     headingName: "Shot Analysis",
                //     selectedClub: null,
                //     onClubSelected: (_) {},
                //   ),
                // ),
                const SizedBox(height: 14),
                const CustomizeBar(),
                const SizedBox(height: 15),
                Expanded(
                  child: _shots.isEmpty
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
                    itemCount: _shots.length,
                    itemBuilder: (context, index) {
                      final shot = _shots[index];
                      return GlassmorphismCard(
                        value: "${shot.value}",
                        name: shot.metric,
                        unit: shot.unit,
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
  }
}
