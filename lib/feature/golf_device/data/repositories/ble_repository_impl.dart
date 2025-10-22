import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:onegolf/feature/golf_device/data/datasources/shot_firestore_datasource.dart';
import 'package:onegolf/feature/golf_device/data/model/shot_anaylsis_model.dart';
import 'package:onegolf/feature/golf_device/domain/entities/shot_anaylsis_entity.dart';
import 'dart:async';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/ble_repository.dart';
import '../services/ble_service.dart';

class BleRepositoryImpl implements BleRepository {
  final BleService _bleService;
  final ShotFirestoreDatasource datasource;

  BleRepositoryImpl(this._bleService, this.datasource);

  @override
  Stream<BleStatus> get statusStream => _bleService.statusStream;

  @override
  Stream<DeviceEntity> scanForDevices() {
    return _bleService.scanForDevices().where((device) {
      return device.name.isNotEmpty &&
          (device.name.startsWith("A-1LM-") || device.name.contains("BM"));
    }).map((device) => DeviceEntity(
          id: device.id,
          name: device.name,
          rssi: device.rssi,
        ));
  }

  @override
  void stopScan() {
    _bleService.stopScan();
  }

  @override
  Stream<DeviceConnectionState> connectToDevice(String deviceId) {
    return _bleService.connectToDevice(deviceId);
  }

  @override
  Future<void> discoverServices(String deviceId) {
    return _bleService.discoverServices(deviceId);
  }

  @override
  Stream<List<int>> subscribeToNotifications() {
    return _bleService.subscribeToNotifications();
  }

  @override
  Future<void> writeData(List<int> data) {
    return _bleService.writeData(data);
  }

  @override
  Future<void> disconnect() {
    return _bleService.disconnect();
  }

  @override
  Future<void> saveShot(ShotAnalysisEntity shot) async {
    final model = ShotAnalysisModel(
      id: '',
      userUid: shot.userUid,
      shotNumber: shot.shotNumber,
      clubName: shot.clubName,
      clubSpeed: shot.clubSpeed,
      smashFactor: shot.smashFactor,
      ballSpeed: shot.ballSpeed,
      carryDistance: shot.carryDistance,
      totalDistance: shot.totalDistance,
      date: shot.date,
      time: shot.time,
      sessionTime: shot.sessionTime,
      timestamp: shot.timestamp,
    );

    await datasource.saveShot(model);
  }

  @override
  Future<void> deleteShot(String userId, String shotId) async {
    await datasource.deleteShot(userId, shotId);
  }

  @override
  Future<List<ShotAnalysisModel>> fetchShotsForUser(String userUid,
      {int limit = 100}) async {
    final raw = await datasource.fetchShotsForUser(userUid, limit: limit);
    return raw;
  }

  @override
  Future<void> deleteAllShotsForUser(String userId) async {
    await datasource.deleteAllShotsForUser(userId);
  }
}
