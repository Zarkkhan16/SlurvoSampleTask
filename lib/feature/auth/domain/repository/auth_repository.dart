import 'package:firebase_auth/firebase_auth.dart';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String name,
  });

  User? getCurrentUser();

  Future<void> logout();
}