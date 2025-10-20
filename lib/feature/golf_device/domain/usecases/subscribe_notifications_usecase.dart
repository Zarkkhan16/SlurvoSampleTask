import '../repositories/ble_repository.dart';
class SubscribeNotificationsUseCase {
  final BleRepository repository;

  SubscribeNotificationsUseCase(this.repository);

  Stream<List<int>> call() {
    return repository.subscribeToNotifications();
  }
}