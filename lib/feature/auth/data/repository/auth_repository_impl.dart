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
  Future<UserEntity> updateProfile(String name) async {
    final user = firebaseAuth.currentUser!;
    await user.updateDisplayName(name);

    await firestore.collection('users').doc(user.uid).update({
      'name': name,
    });

    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      name: name,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = firebaseAuth.currentUser!;
    final email = user.email!;

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    // 🔴 THIS MUST THROW if password is wrong
    await user.reauthenticateWithCredential(credential);

    // 🔴 THIS RUNS ONLY IF RE-AUTH SUCCESS
    await user.updatePassword(newPassword);
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
