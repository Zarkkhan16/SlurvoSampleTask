import '../repositories/ble_repository.dart';
class SendSyncPacketUseCase {
  final BleRepository repository;

  SendSyncPacketUseCase(this.repository);

  Future<void> call(int clubId) {
    int checksum = (0x01 + clubId) & 0xFF;
    return repository.writeData([0x47, 0x46, 0x01, clubId, 0x00, checksum]);
  }
}