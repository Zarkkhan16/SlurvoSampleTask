import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../model/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({required this.firebaseAuth, required this.firestore,});

  @override
  Future<UserEntity?> login(String email, String password) async {
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
  }

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user?.updateDisplayName(name);

    if (userCredential.user != null) {
      final uid = userCredential.user!.uid;

      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        profileImage: '',
        createdAt: Timestamp.now(),
      );

      await firestore.collection('users').doc(uid).set(newUser.toMap());

      return UserEntity(
        uid: uid,
        email: email,
        name: name,
      );
    }

    return null;
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
