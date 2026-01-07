import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<UserEntity> call(String name) async {
    return await repository.updateProfile(name);
  }
}
