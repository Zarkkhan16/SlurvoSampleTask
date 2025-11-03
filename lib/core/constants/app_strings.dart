import 'package:onegolf/feature/landing_dashboard/domain/entities/user_profile.dart';

class AppStrings {
  static const String appTitle = 'BLE App';
  static const String slurvoTitle = 'SLURVO';
  static UserProfile userProfileData = UserProfile(uid: "", name: "", email: "");
  static const String shotAnalysisTitle = 'Shot Analysis';
  static const String customizeText = 'Customize';
  static const String deleteShotText = 'Delete Shot';
  static const String dispersionText = 'Dispersion';
  static const String sessionViewText = 'Session View';
  static const String sessionEndText = 'Session End';

  // Navigation labels
  static const String homePageLabel = 'Home Page';
  static const String shotAnalysisLabel = 'Shot Analysis';
  static const String practiceGamesLabel = 'Practice Games';
  static const String shotLibraryLabel = 'Shot Library';

  // Metrics
  static const String clubSpeedMetric = 'Club Speed';
  static const String ballSpeedMetric = 'Ball Speed';
  static const String distanceMetric = 'Distance';
  static const String launchAngleMetric = 'Launch Angle';
  static const String spinRateMetric = 'Spin Rate';
  static const String unknown = 'Unknown';

  // Units
  static const String mphUnit = 'MPH';
  static const String yardsUnit = 'YDS';
  static const String degreeUnit = '°';
  static const String rpmUnit = 'RPM';

  //msgs

  static const String deviceNotFound = 'Device with UUID 0XFFE0 not found, showing mock data.';
  static const String scanning = 'Scanning for BLE devices...';
  static const String noDataShowing = 'No BLE devices found, showing demo data...';
  static const String connecting = 'Connecting to device...';
  static const String turnOnBluetooth = 'Turn on your Bluetooth for connectivity';

  static const String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String writeCharacteristicUuid = "0000fee1-0000-1000-8000-00805f9b34fb";
  static const String notifyCharacteristicUuid = "0000fee2-0000-1000-8000-00805f9b34fb";



  static const clubs = [
    "1W", "2W", "3W", "5W", "7W",
    "2H", "3H", "4H", "5H",
    "1i", "2i", "3i", "4i", "5i", "6i", "7i", "8i", "9i",
    "PW", "GW", "GW1", "SW", "SW1", "LW", "LW1"
  ];

  static const clubLofts = [
    "10", "13", "15", "17", "21",
    "17", "19", "21", "24",
    "14", "18", "21", "23", "26", "29", "33", "37", "41",
    "46", "50", "52", "54", "56", "58", "60"
  ];

  /// Get loft against index
  static String getLoft(int index) => clubLofts[index];

  /// Get club name against index
  static String getClub(int index) => clubs[index];
}