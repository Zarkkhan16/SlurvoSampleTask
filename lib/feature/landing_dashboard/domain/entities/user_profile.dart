
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? createdAt;


  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [uid, name, email, photoUrl, createdAt];
}