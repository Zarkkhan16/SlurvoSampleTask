import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

abstract class UserRemoteDataSource {
  Future<UserProfileModel?> getUserProfile(String uid);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      // First try to get from Firestore
      final doc = await firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserProfileModel.fromJson(doc.data()!);
      }

      // Fallback to Firebase Auth current user
      final user = firebaseAuth.currentUser;
      if (user != null) {
        return UserProfileModel.fromFirebaseUser(user);
      }

      return null;
    } catch (e) {
      // Fallback to Firebase Auth
      final user = firebaseAuth.currentUser;
      if (user != null) {
        return UserProfileModel.fromFirebaseUser(user);
      }
      return null;
    }
  }
}