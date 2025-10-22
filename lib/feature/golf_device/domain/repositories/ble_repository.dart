import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:onegolf/feature/golf_device/data/model/shot_anaylsis_model.dart';
import 'package:onegolf/feature/golf_device/domain/entities/device_entity.dart' show DeviceEntity;

import '../entities/shot_anaylsis_entity.dart';

abstract class BleRepository {
  Stream<BleStatus> get statusStream;
  Stream<DeviceEntity> scanForDevices();
  void stopScan();
  Stream<DeviceConnectionState> connectToDevice(String deviceId);
  Future<void> discoverServices(String deviceId);
  Stream<List<int>> subscribeToNotifications();
  Future<void> writeData(List<int> data);
  Future<void> disconnect();
  Future<void> saveShot(ShotAnalysisModel shot);
  Future<void> deleteShot(String userId, String shotId);
  Future<List<ShotAnalysisModel>> fetchShotsForUser(String userUid, {int limit = 100});
  Future<void> deleteAllShotsForUser(String userId,);
}
