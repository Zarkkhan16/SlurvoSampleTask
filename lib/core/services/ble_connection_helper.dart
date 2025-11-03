import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../feature/ble_management/presentation/bloc/ble_management_bloc.dart';
import '../../feature/ble_management/presentation/bloc/ble_management_event.dart';
import '../../feature/ble_management/presentation/bloc/ble_management_state.dart';
import '../../feature/ble_management/presentation/widgets/ble_connection_dialog.dart';

class BleConnectionHelper {
  static Future<bool> ensureDeviceConnected(BuildContext context) async {
    print('🔍 BleConnectionHelper: Checking device connection...');

    final bleBloc = context.read<BleManagementBloc>();

    bleBloc.add(CheckConnectionStatusEvent());

    await Future.delayed(const Duration(milliseconds: 200));

    final currentState = bleBloc.state;

    print('📊 Current BLE State: ${currentState.runtimeType}');

    if (currentState is BleConnectedState) {
      print('✅ Device already connected!');
      print('   Device ID: ${currentState.deviceId}');
      print('   Device Name: ${currentState.deviceName}');
      return true;
    }

    print('⚠️ Device not connected. Showing connection dialog...');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bleBloc,
          child: BleConnectionDialog(
            onConnected: () {
              print('✅ Connection dialog: Device connected callback');
            },
            onCancelled: () {
              print('❌ Connection dialog: User cancelled');
            },
          ),
        );
      },
    );

    final isConnected = result ?? false;
    print('🎯 Connection result: $isConnected');

    return isConnected;
  }

  /// Get connection status without showing dialog
  static bool isConnected(BuildContext context) {
    final bleBloc = context.read<BleManagementBloc>();
    final currentState = bleBloc.state;

    final connected = currentState is BleConnectedState;
    print('🔍 Quick connection check: $connected');

    return connected;
  }

  /// Get connected device name
  static String? getConnectedDeviceName(BuildContext context) {
    final bleBloc = context.read<BleManagementBloc>();
    final currentState = bleBloc.state;

    if (currentState is BleConnectedState) {
      print('📱 Connected device: ${currentState.deviceName}');
      return currentState.deviceName;
    }

    print('❌ No device connected');
    return null;
  }

  /// Get connected device ID
  static String? getConnectedDeviceId(BuildContext context) {
    final bleBloc = context.read<BleManagementBloc>();
    final currentState = bleBloc.state;

    if (currentState is BleConnectedState) {
      print('🆔 Connected device ID: ${currentState.deviceId}');
      return currentState.deviceId;
    }

    print('❌ No device ID available');
    return null;
  }
}