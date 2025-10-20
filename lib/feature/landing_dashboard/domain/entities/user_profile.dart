
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, name, email, photoUrl];
}