import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/user_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final UserRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      return await remoteDataSource.getUserProfile(uid);
    } catch (e) {
      return null;
    }
  }
}