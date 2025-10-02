import 'dart:async';
import 'package:OneGolf/core/constants/app_constants.dart';
import 'package:OneGolf/core/constants/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:OneGolf/feature/ble/domain/entities/ble_device.dart';
import 'package:OneGolf/feature/ble/domain/entities/ble_service.dart';
import 'package:OneGolf/feature/ble/domain/entities/ble_characteristic.dart';
import 'package:OneGolf/feature/home_screens/domain/repositories/shot_repository.dart';
import '../../../home_screens/domain/entities/shot_parser.dart';
import 'ble_event.dart';
import 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  final FlutterReactiveBle _ble;
  final ShotRepository shotRepository;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  Timer? _connectionTimer;
  String? _currentConnectingDeviceId;
  String? _currentConnectingDeviceName;
  StreamSubscription<List<int>>? _notifySub;
  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;
  DiscoveredDevice? connectedDevice;

  Timer? _syncTimer;

  BleBloc({required FlutterReactiveBle ble, required this.shotRepository})
      : _ble = ble,
        super(BleInitial()) {
    on<StartScanEvent>(_onStartScan);
    on<StopScanEvent>(_onStopScan);
    on<ConnectToDeviceEvent>(_onConnectToDevice);
    on<DisconnectDeviceEvent>(_onDisconnectDevice);
    on<ReadCharacteristicEvent>(_onReadCharacteristic);
    on<WriteCharacteristicEvent>(_onWriteCharacteristic);
    on<ScannedDevicesEvent>(_onScannedDevices);
    on<ShowMockDataEvent>(_onShowMockData);
    on<ConnectionTimeoutEvent>(_onConnectionTimeout);
    on<ConnectionStateEvent>(_onConnectionState);
    on<RequestPairingEvent>(_onRequestPairing);
  }

  Future<void> _onStartScan(
      StartScanEvent event, Emitter<BleState> emit) async {
    _cancelConnectionAttempt();
    emit(BleScanning());

    _scanSubscription?.cancel();
    final scannedDevices = <BleDevice>[];

    _scanSubscription = _ble.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      final bleDevice = BleDevice(
        id: device.id,
        name: device.name.isNotEmpty ? device.name : "Unknown Device",
        type: "BLE",
        rssi: device.rssi,
        isConnected: false,
      );

      scannedDevices.removeWhere((d) => d.id == bleDevice.id);
      scannedDevices.add(bleDevice);
      scannedDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

      // Filter for specific device after each scan
      final matchingDevices = scannedDevices
          .where((d) =>
              d.id == AppConstants.bleId ||
              d.name.contains(AppConstants.bleName1))
          .toList();

      if (!isClosed) add(ScannedDevicesEvent(matchingDevices));
    }, onError: (error) {
      if (!isClosed) emit(BleError(message: "Scanning failed: $error"));
    });

    // Stop scanning after 30 seconds
    Timer(const Duration(seconds: 30), () {
      if (!isClosed) {
        _scanSubscription?.cancel();

        final matchingDevices = scannedDevices
            .where((d) =>
                d.id == AppConstants.bleId ||
                d.name.contains(AppConstants.bleName1) ||
                d.name.contains(AppConstants.bleName2))
            .toList();

        if (matchingDevices.isEmpty && state is BleScanning) {
          emit(BleError(
              message:
                  "No matching devices found. Ensure your device is nearby and discoverable."));
        }
      }
    });
  }

  void _onStopScan(StopScanEvent event, Emitter<BleState> emit) {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(BleInitial());
  }

  // Future<void> _onConnectToDevice(
  //     ConnectToDeviceEvent event, Emitter<BleState> emit) async {
  //   _scanSubscription?.cancel();
  //   _cancelConnectionAttempt();
  //
  //   _currentConnectingDeviceId = event.deviceId;
  //   _currentConnectingDeviceName = event.deviceName;
  //   emit(BleConnecting(deviceName: event.deviceName ?? "Unknown Device"));
  //
  //   _connectionTimer = Timer(const Duration(seconds: 10), () {
  //     if (!isClosed && _currentConnectingDeviceId == event.deviceId) {
  //       add(ConnectionTimeoutEvent(event.deviceId));
  //     }
  //   });
  //
  //   try {
  //     _connectionSubscription = _ble
  //         .connectToDevice(
  //       id: event.deviceId,
  //       connectionTimeout: const Duration(seconds: 8),
  //     )
  //         .listen((update) async {
  //       if (!isClosed) {
  //         add(ConnectionStateEvent(event.deviceId, update.connectionState));
  //       }
  //
  //       // ✅ when connected
  //       if (update.connectionState == DeviceConnectionState.connected) {
  //         _connectionTimer?.cancel();
  //
  //         // discover services
  //         final services = await _ble.discoverServices(event.deviceId);
  //         print('aasaaas');
  //         print(services);
  //
  //         // find service + chars
  //         final serviceId = Uuid.parse("0000FFE0-0000-1000-8000-00805F9B34FB");
  //         final readId = Uuid.parse("0000FEE2-0000-1000-8000-00805F9B34FB");
  //         final writeId = Uuid.parse("0000FEE1-0000-1000-8000-00805F9B34FB");
  //
  //         final readChar = QualifiedCharacteristic(
  //           serviceId: serviceId,
  //           characteristicId: readId,
  //           deviceId: event.deviceId,
  //         );
  //         final writeChar = QualifiedCharacteristic(
  //           serviceId: serviceId,
  //           characteristicId: writeId,
  //           deviceId: event.deviceId,
  //         );
  //
  //         // ✅ subscribe to notify FEE2
  //         print('✅ subscribe to notify FEE2');
  //         _notifySub?.cancel();
  //         _notifySub =
  //             _ble.subscribeToCharacteristic(readChar).listen((rawData) {
  //           if (rawData.isNotEmpty) {
  //             final parsed = ShotParser.parse(rawData);
  //             emit(BleShotData(parsed));
  //           }
  //         });
  //
  //         // ✅ send sync packet every second
  //
  //         print('✅ send sync packet every second');
  //         _syncTimer?.cancel();
  //         _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
  //           final packet = [0x47, 0x46, 0x01, 0x00, 0x00, 0x01];
  //           try {
  //             await _ble.writeCharacteristicWithResponse(
  //               writeChar,
  //               value: packet,
  //             );
  //           } catch (e) {
  //             emit(BleError(message: "Sync write failed: $e"));
  //           }
  //         });
  //
  //         // emit(BleConnected(services)); // still show services if needed
  //       }
  //     }, onError: (error) {
  //       _connectionTimer?.cancel();
  //       if (!isClosed) {
  //         add(ConnectionTimeoutEvent(event.deviceId, error: error.toString()));
  //       }
  //     }, onDone: () => _connectionTimer?.cancel());
  //   } catch (e) {
  //     _connectionTimer?.cancel();
  //     if (!isClosed) {
  //       emit(BleError(message: "Failed to start connection: $e"));
  //     }
  //   }
  // }

  // Future<void> _onConnectToDevice(
  //     ConnectToDeviceEvent event, Emitter<BleState> emit) async {
  //   _scanSubscription?.cancel();
  //   _cancelConnectionAttempt();
  //
  //   _currentConnectingDeviceId = event.deviceId;
  //   _currentConnectingDeviceName = event.deviceName;
  //   emit(BleConnecting(deviceName: event.deviceName ?? "Unknown Device"));
  //
  //   _connectionTimer = Timer(const Duration(seconds: 10), () {
  //     if (!isClosed && _currentConnectingDeviceId == event.deviceId) {
  //       add(ConnectionTimeoutEvent(event.deviceId));
  //     }
  //   });
  //
  //   try {
  //     _connectionSubscription = _ble
  //         .connectToDevice(
  //       id: event.deviceId,
  //       connectionTimeout: const Duration(seconds: 8),
  //     )
  //         .listen((update) async {
  //       if (!isClosed) {
  //         add(ConnectionStateEvent(event.deviceId, update.connectionState));
  //       }
  //
  //       // ✅ when connected
  //       if (update.connectionState == DeviceConnectionState.connected) {
  //         _connectionTimer?.cancel();
  //
  //         try {
  //           // discover services
  //           final services = await _ble.discoverServices(event.deviceId);
  //           if (!isClosed) {
  //             print("✅ Services discovered: $services");
  //           }
  //
  //           // find service + chars
  //           final serviceId =
  //           Uuid.parse("0000FFE0-0000-1000-8000-00805F9B34FB");
  //           final readId =
  //           Uuid.parse("0000FEE2-0000-1000-8000-00805F9B34FB");
  //           final writeId =
  //           Uuid.parse("0000FEE1-0000-1000-8000-00805F9B34FB");
  //
  //
  //           final writeChar = QualifiedCharacteristic(
  //             serviceId: serviceId,
  //             characteristicId: writeId,
  //             deviceId: event.deviceId,
  //           );
  //           final readChar = QualifiedCharacteristic(
  //             serviceId: serviceId,
  //             characteristicId: readId,
  //             deviceId: event.deviceId,
  //           );
  //
  //           // ✅ subscribe to notify FEE2
  //           // _notifySub?.cancel();
  //           // _notifySub = _ble.subscribeToCharacteristic(readChar).listen(
  //           //       (rawData) {
  //           //     if (!isClosed) {
  //           //       if (rawData.isNotEmpty) {
  //           //         final parsed = ShotParser.parse(rawData);
  //           //         emit(BleShotData(parsed));
  //           //       }
  //           //     }
  //           //   },
  //           //   onError: (err) {
  //           //         print(err);
  //           //         print('[[[[eeeeeeerrrrrr[[[[');
  //           //     if (!isClosed) {
  //           //       emit(BleError(message: "Notify error: $err"));
  //           //     }
  //           //   },
  //           // );
  //
  //           // ✅ send sync packet every second
  //           _syncTimer?.cancel();
  //           _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
  //             print('Send Data');
  //             // if (isClosed) return;
  //             final packet = [47, 46, 01, 00, 00, 01];
  //             final data = Uint8List.fromList(packet);
  //             print(data);
  //             print('[[[[[[2222');
  //             print(packet);
  //
  //             print('[[[[[[[[[[[[[[[[[[[[[[[[[[');
  //             try {
  //               await _ble.writeCharacteristicWithResponse(
  //                 writeChar,
  //                 value: packet,
  //               );
  //               _notifySub?.cancel();
  //               _notifySub = _ble.subscribeToCharacteristic(readChar).listen(
  //                     (rawData) {
  //                       print(rawData);
  //                       print('ssssss');
  //                   if (!isClosed) {
  //                     if (rawData.isNotEmpty) {
  //                       final parsed = ShotParser.parse(rawData);
  //                       emit(BleShotData(parsed));
  //                     }
  //                   }
  //                 },
  //                 onError: (err) {
  //                   print(err);
  //                   print('[[[[eeeeeeerrrrrr[[[[');
  //                   if (!isClosed) {
  //                     emit(BleError(message: "Notify error: $err"));
  //                   }
  //                 },
  //               );
  //             } catch (e) {
  //               if (!isClosed) {
  //                 emit(BleError(message: "Sync write failed: $e"));
  //               }
  //             }
  //           });
  //         } catch (e) {
  //           if (!isClosed) {
  //             emit(BleError(message: "Service discovery failed: $e"));
  //           }
  //         }
  //       }
  //     }, onError: (error) {
  //       _connectionTimer?.cancel();
  //       if (!isClosed) add(ConnectionTimeoutEvent(event.deviceId, error: error.toString()));
  //     }, onDone: () => _connectionTimer?.cancel());
  //   } catch (e) {
  //     _connectionTimer?.cancel();
  //     if (!isClosed) emit(BleError(message: "Failed to start connection: $e"));
  //   }
  // }
  // Future<void> _onConnectToDevice(
  //     ConnectToDeviceEvent event, Emitter<BleState> emit) async {
  //   _scanSubscription?.cancel();
  //   // _cancelConnectionAttempt();
  //
  //   // _currentConnectingDeviceId = event.deviceId;
  //   // _currentConnectingDeviceName = event.deviceName;
  //   // emit(BleConnecting(deviceName: event.deviceName ?? "Unknown Device"));
  //
  //   // _connectionTimer = Timer(const Duration(seconds: 10), () {
  //   //   if (!isClosed && _currentConnectingDeviceId == event.deviceId) {
  //   //     add(ConnectionTimeoutEvent(event.deviceId));
  //   //   }
  //   // });
  //
  //   try {
  //     _connectionSubscription = _ble.connectToDevice(
  //       id: event.deviceId,
  //       connectionTimeout: const Duration(seconds: 8),
  //     ).listen((update) async {
  //       if (!isClosed) {
  //         add(ConnectionStateEvent(event.deviceId, update.connectionState));
  //       }
  //
  //       if (update.connectionState == DeviceConnectionState.connected) {
  //         // _connectionTimer?.cancel();
  //
  //         try {
  //           final services = await _ble.discoverServices(event.deviceId);
  //           print("✅ Services discovered: $services");
  //
  //           // // Find FFE0 service
  //           // final targetService = services.firstWhere(
  //           //       (s) => s.serviceId.toString().toLowerCase() ==
  //           //       "0000ffe0-0000-1000-8000-00805f9b34fb",
  //           //   orElse: () => throw Exception("FFE0 service not found"),
  //           // );
  //           //
  //           // // Find FEE1 (write) and FEE2 (notify)
  //           // final writeCharId = targetService.characteristicIds.firstWhere(
  //           //       (c) => c.toString().toLowerCase() ==
  //           //       "0000fee1-0000-1000-8000-00805f9b34fb",
  //           //   orElse: () => throw Exception("FEE1 write characteristic not found"),
  //           // );
  //           //
  //           // final readCharId = targetService.characteristicIds.firstWhere(
  //           //       (c) => c.toString().toLowerCase() ==
  //           //       "0000fee2-0000-1000-8000-00805f9b34fb",
  //           //   orElse: () => throw Exception("FEE2 notify characteristic not found"),
  //           // );
  //           //
  //           // print("📝 WriteChar: $writeCharId");
  //           // print("👂 ReadChar:  $readCharId");
  //
  //           final characteristic = QualifiedCharacteristic(
  //             serviceId: Uuid.parse(AppStrings.serviceUuid),
  //             characteristicId: Uuid.parse(AppStrings.notifyCharacteristicUuid),
  //             deviceId: event.deviceId,
  //           );
  //
  //           _notifySub = _ble.subscribeToCharacteristic(characteristic).listen((data){
  //             if(data.isNotEmpty)
  //               {
  //                 final parsed = ShotParser.parse(data);
  //                 emit(BleShotData(parsed));
  //               }
  //           });
  //
  //
  //           // final writeChar = QualifiedCharacteristic(
  //           //   serviceId: targetService.serviceId,
  //           //   characteristicId: writeCharId,
  //           //   deviceId: event.deviceId,
  //           // );
  //           //
  //           // final readChar = QualifiedCharacteristic(
  //           //   serviceId: targetService.serviceId,
  //           //   characteristicId: readCharId,
  //           //   deviceId: event.deviceId,
  //           // );
  //
  //           // Subscribe once
  //           // _notifySub?.cancel();
  //           // _notifySub = _ble.subscribeToCharacteristic(readChar).listen(
  //           //       (rawData) {
  //           //     print("📥 Notify Data: $rawData");
  //           //     if (!isClosed && rawData.isNotEmpty) {
  //           //       final parsed = ShotParser.parse(rawData);
  //           //       emit(BleShotData(parsed));
  //           //     }
  //           //   },
  //           //   onError: (err) {
  //           //     print("❌ Notify error: $err");
  //           //     if (!isClosed) {
  //           //       emit(BleError(message: "Notify error: $err"));
  //           //     }
  //           //   },
  //           // );
  //
  //           // Send HEX command
  //           _startSyncTimer();
  //           // final command =
  //           // Uint8List.fromList([0x47, 0x46, 0x01, 0x00, 0x00, 0x01]);
  //           //
  //           // final hexStr = command
  //           //     .map((b) => b.toRadixString(16).padLeft(2, '0'))
  //           //     .join(' ');
  //           // print("📤 Sending packet: $hexStr");
  //           //
  //           // await _ble.writeCharacteristicWithResponse(
  //           //   writeChar,
  //           //   value: command,
  //           // );
  //           //
  //           // print("✅ Write successful");
  //         } catch (e) {
  //           // if (!isClosed) {
  //           //   emit(BleError(message: "Service discovery failed: $e"));
  //           // }
  //         }
  //       }
  //     }, onError: (error) {
  //       _connectionTimer?.cancel();
  //       if (!isClosed) {
  //         add(ConnectionTimeoutEvent(event.deviceId, error: error.toString()));
  //       }
  //     }, onDone: () => _connectionTimer?.cancel());
  //   } catch (e) {
  //     _connectionTimer?.cancel();
  //     if (!isClosed) {
  //       emit(BleError(message: "Failed to start connection: $e"));
  //     }
  //   }
  // }

  Future<void> _onConnectToDevice(
      ConnectToDeviceEvent event, Emitter<BleState> emit) async {
    _scanSubscription?.cancel();
    _cancelConnectionAttempt();

    _currentConnectingDeviceId = event.deviceId;
    _currentConnectingDeviceName = event.deviceName;
    emit(BleConnecting(deviceName: event.deviceName ?? "Unknown Device"));

    try {
      _connectionSubscription = _ble
          .connectToDevice(
        id: event.deviceId,
        connectionTimeout: const Duration(seconds: 8),
      )
          .listen((update) async {
        if (!isClosed) {
          add(ConnectionStateEvent(event.deviceId, update.connectionState));
        }

        if (update.connectionState == DeviceConnectionState.connected) {
          // discover services
          final services = await _ble.discoverServices(event.deviceId);
          print("✅ Services discovered: $services");

          final serviceId = Uuid.parse("0000FFE0-0000-1000-8000-00805F9B34FB");
          final readId = Uuid.parse("0000FEE2-0000-1000-8000-00805F9B34FB");
          final writeId = Uuid.parse("0000FEE1-0000-1000-8000-00805F9B34FB");

          final readChar = QualifiedCharacteristic(
            serviceId: serviceId,
            characteristicId: readId,
            deviceId: event.deviceId,
          );
          final writeChar = QualifiedCharacteristic(
            serviceId: serviceId,
            characteristicId: writeId,
            deviceId: event.deviceId,
          );

          // ✅ subscribe ONCE
          _notifySub?.cancel();
          _notifySub = _ble.subscribeToCharacteristic(readChar).listen(
                (rawData) {
              if (rawData.isNotEmpty) {
                final parsed = ShotParser.parse(rawData);
                emit(BleShotData(parsed));
              }
            },
            onError: (err) => emit(BleError(message: "Notify error: $err")),
          );

          await Future.delayed(const Duration(milliseconds: 300));

          // ✅ send first sync immediately
          final firstPacket = [0x47, 0x46, 0x01, 0x00, 0x00, 0x01];
          await _ble.writeCharacteristicWithResponse(writeChar, value: firstPacket);

          // ✅ keep sending sync every second
          _syncTimer?.cancel();
          _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
            try {
              await _ble.writeCharacteristicWithResponse(
                writeChar,
                value: firstPacket,
              );
            } catch (e) {
              emit(BleError(message: "Sync write failed: $e"));
            }
          });

          // emit(BleConnected(
          //   BleDevice(event.deviceId, event.deviceName ?? "Device", "BLE", 0, true, id: '', name: '', type: '', rssi: null),
          //   services.map((s) => BleService.fromDiscovered(s)).toList(),
          // ));
        }
      }, onError: (error) {
        if (!isClosed) emit(BleError(message: "Connection error: $error"));
      });
    } catch (e) {
      if (!isClosed) emit(BleError(message: "Failed to connect: $e"));
    }
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _sendSyncPacket();
    });
  }
  void _sendSyncPacket() {
    if (connectedDevice == null || connectionState != DeviceConnectionState.connected) return;
    int clubId = ShotParser.clubName; // <-- your current club index
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
        serviceId: Uuid.parse(AppStrings.serviceUuid),
        characteristicId: Uuid.parse(AppStrings.writeCharacteristicUuid),
        deviceId: connectedDevice!.id,
      );
      print('Data ${data}');

      await _ble.writeCharacteristicWithoutResponse(
        characteristic,
        value: data,
      );
    } catch (e) {
      // _addLog('Write error: $e');
    }
  }


    Future<void> _onConnectionState(ConnectionStateEvent event, Emitter<BleState> emit) async {
    switch (event.connectionState) {
      case DeviceConnectionState.connected:
        _connectionTimer?.cancel();
        try {
          print(event.deviceId);
          print(event.deviceId);
          await Future.delayed(Duration(milliseconds: 500));

          final services = await _ble.discoverServices(event.deviceId);

          final bleServices = services.map((s) => BleService(
            uuid: s.serviceId.toString(),
            characteristics: s.characteristics.map((c) => BleCharacteristic(
              uuid: c.characteristicId.toString(),
              canRead: c.isReadable,
              canWrite: c.isWritableWithResponse || c.isWritableWithoutResponse,
              canNotify: c.isNotifiable,
              value: null,
            )).toList(),
          )).toList();

          emit(BleConnected(
            device: BleDevice(
              id: event.deviceId,
              name: _currentConnectingDeviceName ?? "Connected Device",
              type: "BLE",
              rssi: 0,
              isConnected: true,
            ),
            services: bleServices,
          ));
          break;
        } catch (e) {
          print(e);
          emit(BleError(message: "Failed to discover services: $e"));
        }
        break;

      case DeviceConnectionState.disconnected:
        _connectionTimer?.cancel();
        emit(_currentConnectingDeviceId == event.deviceId ? BleError(message: "Device disconnected unexpectedly") : BleDisconnected());
        break;

      default:
        break;
    }
  }

  void _cancelConnectionAttempt() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _currentConnectingDeviceId = null;
    _currentConnectingDeviceName = null;
  }

  Future<void> _onDisconnectDevice(DisconnectDeviceEvent event, Emitter<BleState> emit) async {
    _cancelConnectionAttempt();
    emit(BleDisconnected());
  }

  Future<void> _onReadCharacteristic(ReadCharacteristicEvent event, Emitter<BleState> emit) async {
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(event.serviceUuid),
        characteristicId: Uuid.parse(event.characteristicUuid),
        deviceId: event.deviceId,
      );
      final value = await _ble.readCharacteristic(characteristic);
      emit(BleCharacteristicRead(data: value));
    } catch (e) {
      emit(BleError(message: "Failed to read characteristic: $e"));
    }
  }

  Future<void> _onWriteCharacteristic(WriteCharacteristicEvent event, Emitter<BleState> emit) async {
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(event.serviceUuid),
        characteristicId: Uuid.parse(event.characteristicUuid),
        deviceId: event.deviceId,
      );
      await _ble.writeCharacteristicWithResponse(characteristic, value: event.data);
      emit(BleCharacteristicWritten());
    } catch (e) {
      emit(BleError(message: "Failed to write characteristic: $e"));
    }
  }

  void _onScannedDevices(ScannedDevicesEvent event, Emitter<BleState> emit) {
    emit(BleScannedDevices(scannedDevice: event.targetDevice));
  }

  Future<void> _onShowMockData(ShowMockDataEvent event, Emitter<BleState> emit) async {
    try {
      final mockData = await shotRepository.getShotData();
      emit(BleMockDataFound(mockData: mockData));
    } catch (e) {
      emit(BleError(message: "Failed to get mock data: $e"));
    }
  }

  void _onConnectionTimeout(ConnectionTimeoutEvent event, Emitter<BleState> emit) {
    _cancelConnectionAttempt();
    emit(BleError(message: event.error != null ? "Connection failed: ${event.error}" : "Connection timeout. Please try again."));
  }

  Future<void> _onRequestPairing(RequestPairingEvent event, Emitter<BleState> emit) async {
    emit(BlePairingRequested(deviceId: event.deviceId, deviceName: event.deviceName));
  }

  @override
  Future<void> close() async {
    _cancelConnectionAttempt();
    await _scanSubscription?.cancel();
    return super.close();
  }
}
