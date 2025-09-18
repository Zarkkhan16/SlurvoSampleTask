import 'package:flutter/material.dart';
import 'package:Slurvo/feature/ble/domain/entities/ble_device.dart';

class DeviceCard extends StatelessWidget {
  final BleDevice device;
  final VoidCallback onConnect;
  final VoidCallback onPair;
  final bool isPaired;
  final double screenWidth;

  const DeviceCard({
    Key? key,
    required this.device,
    required this.onConnect,
    required this.onPair,
    required this.isPaired,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = screenWidth * 0.045;
    final subtitleSize = screenWidth * 0.035;
    final spacing = screenWidth * 0.04;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing * 0.25,
      ),
      color: Colors.grey[900],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isPaired
              ? Border.all(color: Colors.green.withOpacity(0.3), width: 1)
              : null,
        ),
        child: ListTile(
          leading: Stack(
            children: [
              Icon(
                Icons.bluetooth,
                color: _getSignalColor(device.rssi),
                size: screenWidth * 0.06,
              ),
              if (isPaired)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[900]!, width: 1),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  device.name.isNotEmpty ? device.name : "Unknown Device",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize.clamp(14.0, 18.0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isPaired)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Text(
                    'PAIRED',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                "ID: ${device.id}",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: subtitleSize.clamp(11.0, 14.0),
                ),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    _getSignalIcon(device.rssi),
                    color: _getSignalColor(device.rssi),
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Signal: ${device.rssi} dBm",
                    style: TextStyle(
                      color: _getSignalColor(device.rssi),
                      fontSize: subtitleSize.clamp(11.0, 14.0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getSignalStrength(device.rssi),
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: subtitleSize.clamp(10.0, 12.0),
                    ),
                  ),
                ],
              ),
              if (_getDeviceType() != null)
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    _getDeviceType()!,
                    style: TextStyle(
                      color: Colors.blue.withOpacity(0.8),
                      fontSize: subtitleSize.clamp(10.0, 12.0),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show pair button if device likely needs pairing and isn't paired
              if (_shouldShowPairButton() && !isPaired)
                IconButton(
                  onPressed: onPair,
                  icon: Icon(
                    Icons.bluetooth_connected,
                    color: Colors.blue,
                    size: screenWidth * 0.05,
                  ),
                  tooltip: "Pair Device",
                ),

              // Connect button
              IconButton(
                onPressed: onConnect,
                icon: Icon(
                  isPaired ? Icons.link : Icons.arrow_forward_ios,
                  color: isPaired ? Colors.green : Colors.white54,
                  size: screenWidth * 0.04,
                ),
                tooltip: isPaired ? "Connect to Paired Device" : "Connect",
              ),
            ],
          ),
          onTap: onConnect,
        ),
      ),
    );
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi >= -50) return Icons.signal_wifi_4_bar;
    if (rssi >= -70) return Icons.signal_wifi_0_bar_sharp;
    return Icons.signal_wifi_0_bar;
  }

  String _getSignalStrength(int rssi) {
    if (rssi >= -50) return "(Excellent)";
    if (rssi >= -70) return "(Good)";
    return "(Weak)";
  }

  String? _getDeviceType() {
    final name = device.name.toLowerCase();
    if (name.contains('headphone') || name.contains('earbuds') || name.contains('airpods')) {
      return "🎧 Audio Device";
    }
    if (name.contains('speaker')) {
      return "🔊 Speaker";
    }
    if (name.contains('keyboard')) {
      return "⌨️ Keyboard";
    }
    if (name.contains('mouse')) {
      return "🖱️ Mouse";
    }
    if (name.contains('watch') || name.contains('band') || name.contains('tracker')) {
      return "⌚ Wearable";
    }
    if (name.contains('phone') || name.contains('mobile')) {
      return "📱 Mobile Device";
    }
    return null;
  }

  bool _shouldShowPairButton() {
    final name = device.name.toLowerCase();
    // Common patterns for devices that typically require pairing
    return name.contains('headphone') ||
        name.contains('speaker') ||
        name.contains('keyboard') ||
        name.contains('mouse') ||
        name.contains('watch') ||
        name.contains('fitness') ||
        name.contains('band') ||
        name.contains('tracker') ||
        name.contains('earbuds') ||
        name.contains('airpods') ||
        name.contains('beats') ||
        name.contains('sony') ||
        name.contains('bose') ||
        name.startsWith('mi ') ||
        name.contains('xiaomi') ||
        device.rssi > -60; // Strong signal might indicate a personal device
  }
}