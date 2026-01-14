import 'package:wakelock_plus/wakelock_plus.dart';

class WakeLockHelper {
  static Future<void> enable() async {
    await WakelockPlus.enable();
    print('🔆 WakeLock ENABLED');
  }

  static Future<void> disable() async {
    await WakelockPlus.disable();
    print('🌙 WakeLock DISABLED');
  }
}
