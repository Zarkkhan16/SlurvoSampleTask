import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  User? call() {
    return repository.getCurrentUser();
  }
}