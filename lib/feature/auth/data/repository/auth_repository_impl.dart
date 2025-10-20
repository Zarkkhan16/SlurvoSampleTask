import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;

  AuthRepositoryImpl({required this.firebaseAuth});

  @override
  Future<UserEntity?> login(String email, String password) async {
    // try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return UserEntity(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? '',
        );
      }
      return null;
    // } catch (e) {
    //   throw Exception('Login failed: ${e.toString()}');
    // }
  }

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      if (userCredential.user != null) {
        return UserEntity(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: name,
        );
      }
      return null;
    // } catch (e) {
    //   throw Exception('Sign up failed: ${e.toString()}');
    // }
  }

  @override
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}
