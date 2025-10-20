
import '../entities/user_profile.dart';

abstract class DashboardRepository {
  Future<UserProfile?> getUserProfile(String uid);
}