import 'dart:typed_data';
import 'package:Slurvo/feature/home_screens/domain/entities/shot_data.dart';

class ShotParser {
  static int clubName = 0;
  static const List<String> CLUB_NAMES = [
    "DR", "2W", "3W", "5W", "7W",
    "2H", "3H", "4H", "5H",
    "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
    "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
  ];

  static const List<String> BATTERY_STATUS = [
    "Blank", "Low", "Middle", "Full"
  ];

  static List<ShotDataNew> parse(List<int> data) {
    if (data.length < 16) {
      return [ShotDataNew(metric: "Error", value: "Data too short", unit: "", displayValue: "Error")];
    }

    final bytes = Uint8List.fromList(data);

    print("????");
    print(data);
    List<ShotDataNew> result = [];

    // Header + CMD
    final header = "${bytes[0].toRadixString(16).toUpperCase()} ${bytes[1].toRadixString(16).toUpperCase()}";
    final cmd = bytes[2];
    if(cmd == 1){
      // Battery (BYTE 4)
      final batteryCode = bytes[3];
      final battery = batteryCode < BATTERY_STATUS.length
          ? BATTERY_STATUS[batteryCode]
          : "Unknown";
      result.add(ShotDataNew(
        metric: "Battery",
        value: batteryCode,
        unit: battery,
        displayValue: battery,
      ));

      // Record number (bytes 4–5, little endian)
      final record = (bytes[4] << 8) | bytes[5];
      result.add(ShotDataNew(
        metric: "Record Number",
        value: record,
        unit: "records",
        displayValue: record.toString(),
      ));

      // Club name (BYTE 7)
      final clubCode = bytes[6];
      clubName = clubCode;
      final club = clubCode < CLUB_NAMES.length ? CLUB_NAMES[clubCode] : "Unknown";
      result.add(ShotDataNew(
        metric: "Club",
        value: clubCode,
        unit: club,
        displayValue: club,
      ));

      // Club Speed (bytes 7–8 → ÷10.0)
      final clubSpeedRaw = (bytes[7] << 8) | bytes[8];
      final clubSpeed = clubSpeedRaw / 10.0;
      result.add(ShotDataNew(
        metric: "Club Speed",
        value: clubSpeed,
        unit: "mph",
        displayValue: "${clubSpeed.toStringAsFixed(1)} mph",
      ));

      // Ball Speed (bytes 9–10 → ÷10.0)
      final ballSpeedRaw = (bytes[9] << 8) | bytes[10];
      final ballSpeed = ballSpeedRaw / 10.0;
      result.add(ShotDataNew(
        metric: "Ball Speed",
        value: ballSpeed,
        unit: "mph",
        displayValue: "${ballSpeed.toStringAsFixed(1)} mph",
      ));

      // Carry Distance (bytes 11–12 → ÷10.0)
      final carryRaw = (bytes[11] << 8) | bytes[12];
      final carry = carryRaw / 10.0;
      result.add(ShotDataNew(
        metric: "Carry Distance",
        value: carry,
        unit: "yards",
        displayValue: "${carry.toStringAsFixed(1)} yards",
      ));

      // Total Distance (bytes 13–14 → ÷10.0)
      final totalRaw = (bytes[13] << 8) | bytes[14];
      final total = totalRaw / 10.0;
      result.add(ShotDataNew(
        metric: "Total Distance",
        value: total,
        unit: "yards",
        displayValue: "${total.toStringAsFixed(1)} yards",
      ));

    }

    // if (cmd == 1) {
    //   // Battery (byte 3)
    //   final batteryCode = bytes[3];
    //   final battery = batteryCode < BATTERY_STATUS.length ? BATTERY_STATUS[batteryCode] : "Unknown";
    //   // result.add(ShotDataNew(
    //   //   metric: "Battery Status",
    //   //   value: batteryCode,
    //   //   unit: battery,
    //   //   displayValue: battery,
    //   // ));
    //
    //   // Record number (bytes 4–5, big endian)
    //   final record = (bytes[4] << 8) | bytes[5];
    //   // result.add(ShotDataNew(
    //   //   metric: "Current Record",
    //   //   value: record,
    //   //   unit: "records",
    //   //   displayValue: record.toString(),
    //   // ));
    //
    //   // Club name (byte 6)
    //   final clubCode = bytes[6];
    //   final club = clubCode < CLUB_NAMES.length ? CLUB_NAMES[clubCode] : "Unknown";
    //   // result.add(ShotDataNew(
    //   //   metric: "Club Name",
    //   //   value: clubCode,
    //   //   unit: club,
    //   //   displayValue: club,
    //   // ));
    //
    //   // Club speed (bytes 7–8, big endian, ÷10)
    //   final clubSpeedRaw = (bytes[7] << 8) | bytes[8];
    //   final clubSpeed = clubSpeedRaw / 10.0;
    //   result.add(ShotDataNew(
    //     metric: "Club Speed",
    //     value: clubSpeed,
    //     unit: "mph",
    //     displayValue: "${clubSpeed.toStringAsFixed(1)} mph",
    //   ));
    //
    //   // Ball speed (bytes 9–10)
    //   final ballSpeedRaw = (bytes[9] << 8) | bytes[10];
    //   final ballSpeed = ballSpeedRaw / 10.0;
    //   result.add(ShotDataNew(
    //     metric: "Ball Speed",
    //     value: ballSpeed,
    //     unit: "mph",
    //     displayValue: "${ballSpeed.toStringAsFixed(1)} mph",
    //   ));
    //
    //   // Carry (bytes 11–12)
    //   final carryRaw = (bytes[11] << 8) | bytes[12];
    //   final carry = carryRaw / 10.0;
    //   result.add(ShotDataNew(
    //     metric: "Carry Distance",
    //     value: carry,
    //     unit: "yards",
    //     displayValue: "${carry.toStringAsFixed(1)} yards",
    //   ));
    //
    //   // Total (bytes 13–14)
    //   final totalRaw = (bytes[13] << 8) | bytes[14];
    //   final total = totalRaw / 10.0;
    //   result.add(ShotDataNew(
    //     metric: "Total Distance",
    //     value: total,
    //     unit: "yards",
    //     displayValue: "${total.toStringAsFixed(1)} yards",
    //   ));
    // }

    // Battery (BYTE 4)
    return result;
  }

  static List<ShotDataNew> parseExampleData() {
    // Example from doc: 47 46 01 01 00 0E 00 04 8A 06 9F 0B 36 0B F0 7F
    final example = [
      0x47, 0x46, 0x01, 0x01,
      0x00, 0x0E, // record
      0x00,       // club = DR
      0x04, 0x8A, // club speed = 1162 -> 116.2 mph
      0x06, 0x9F, // ball speed = 1695 -> 169.5 mph
      0x0B, 0x36, // carry = 2870 -> 287.0 yd
      0x0B, 0xF0, // total = 3056 -> 305.6 yd
      0x7F
    ];
    return parse(example);
  }
}
