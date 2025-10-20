
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    super.photoUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory UserProfileModel.fromFirebaseUser(dynamic user) {
    return UserProfileModel(
      uid: user.uid ?? '',
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }
}