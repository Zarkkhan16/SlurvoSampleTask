import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final UserEntity user;

  AuthLoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignUpSuccess extends AuthState {
  final UserEntity user;

  AuthSignUpSuccess(this.user);

  @override
  List<Object?> get props => [user];
}
class AuthLoginFailure extends AuthState {
  final String message;

  AuthLoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSignUpFailure extends AuthState {
  final String message;

  AuthSignUpFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}