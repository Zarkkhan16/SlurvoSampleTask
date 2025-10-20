import '../repositories/ble_repository.dart';
class SendCommandUseCase {
  final BleRepository repository;

  SendCommandUseCase(this.repository);

  Future<void> call(int cmd, int param1, int param2) {
    List<int> packet = [0x47, 0x46, cmd, param1, param2];
    int checksum = packet.skip(2).fold(0, (sum, byte) => sum + byte) & 0xFF;
    packet.add(checksum);
    return repository.writeData(packet);
  }
}