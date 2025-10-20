import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/signup_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final SignUpUser signUpUser;
  final CheckAuthStatus checkAuthStatus;
  final LogoutUser logoutUser;

  AuthBloc({
    required this.loginUser,
    required this.signUpUser,
    required this.checkAuthStatus,
    required this.logoutUser,
  }) : super(AuthInitial()) {

    on<CheckAuthStatusEvent>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(milliseconds: 500));

      final user = checkAuthStatus();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });

    // Login Event Handler
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUser(event.email, event.password);
        if (user != null) {
          emit(AuthLoginSuccess(user));
        } else {
          emit(AuthLoginFailure("Login failed"));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthLoginFailure(_getFirebaseAuthErrorMessage(e.code)));
      } catch (e) {
        emit(AuthLoginFailure("An unexpected error occurred. Please try again."));
      }
    });

    // SignUp Event Handler
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signUpUser(
          email: event.email,
          password: event.password,
          name: event.name,
        );
        if (user != null) {
          emit(AuthSignUpSuccess(user));
        } else {
          emit(AuthSignUpFailure("Sign up failed"));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthSignUpFailure(_getFirebaseAuthErrorMessage(e.code)));
      } catch (e) {
        emit(AuthSignUpFailure("An unexpected error occurred. Please try again."));
      }
    });


    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await logoutUser();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthLoginFailure("Logout failed. Please try again."));
      }
    });
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
    // Login errors
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address. Please check and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';

    // SignUp errors
      case 'email-already-in-use':
        return 'An account already exists with this email. Please login.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Contact support.';

    // Network errors
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

    // Default
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
