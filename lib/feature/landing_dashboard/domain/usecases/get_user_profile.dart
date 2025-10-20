
import '../entities/user_profile.dart';
import '../repositories/dashboard_repository.dart';

class GetUserProfile {
  final DashboardRepository repository;

  GetUserProfile(this.repository);

  Future<UserProfile?> call(String uid) async {
    return await repository.getUserProfile(uid);
  }
}