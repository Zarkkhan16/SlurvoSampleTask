import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

class SignUpUser {
  final AuthRepository repository;

  SignUpUser(this.repository);

  Future<UserEntity?> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      name: name,
    );
  }
}