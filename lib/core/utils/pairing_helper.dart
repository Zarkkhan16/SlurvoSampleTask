// Create a new file: bluetooth_pairing_helper.dart

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BluetoothPairingHelper {
  static const MethodChannel _channel = MethodChannel('bluetooth_pairing');

  /// Check if device is already paired
  static Future<bool> isDevicePaired(String deviceAddress) async {
    try {
      final bool isPaired = await _channel.invokeMethod('isDevicePaired', {
        'deviceAddress': deviceAddress,
      });
      return isPaired;
    } catch (e) {
      print('Error checking pairing status: $e');
      return false;
    }
  }

  /// Request pairing with device
  static Future<bool> requestPairing(String deviceAddress) async {
    try {
      final bool success = await _channel.invokeMethod('requestPairing', {
        'deviceAddress': deviceAddress,
      });
      return success;
    } catch (e) {
      print('Error requesting pairing: $e');
      return false;
    }
  }

  /// Open Bluetooth settings
  static Future<bool> openBluetoothSettings() async {
    try {
      // Try to open Android Bluetooth settings
      if (await canLaunchUrl(Uri.parse('android.settings.BLUETOOTH_SETTINGS'))) {
        return await launchUrl(
          Uri.parse('android.settings.BLUETOOTH_SETTINGS'),
          mode: LaunchMode.externalApplication,
        );
      }

      // Fallback to general settings
      if (await canLaunchUrl(Uri.parse('android.settings.SETTINGS'))) {
        return await launchUrl(
          Uri.parse('android.settings.SETTINGS'),
          mode: LaunchMode.externalApplication,
        );
      }

      return false;
    } catch (e) {
      print('Error opening Bluetooth settings: $e');
      return false;
    }
  }

  /// Get list of paired devices
  static Future<List<Map<String, dynamic>>> getPairedDevices() async {
    try {
      final List<dynamic> devices = await _channel.invokeMethod('getPairedDevices');
      return devices.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }

  /// Check if Bluetooth is enabled
  static Future<bool> isBluetoothEnabled() async {
    try {
      final bool isEnabled = await _channel.invokeMethod('isBluetoothEnabled');
      return isEnabled;
    } catch (e) {
      print('Error checking Bluetooth status: $e');
      return false;
    }
  }

  /// Request to enable Bluetooth
  static Future<bool> requestEnableBluetooth() async {
    try {
      final bool success = await _channel.invokeMethod('requestEnableBluetooth');
      return success;
    } catch (e) {
      print('Error requesting Bluetooth enable: $e');
      return false;
    }
  }
}