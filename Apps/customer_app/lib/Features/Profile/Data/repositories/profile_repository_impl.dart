import '../../Domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../Models/profile_user_model.dart';

/// ProfileRepositoryImpl - Implementation of ProfileRepository
/// 
/// Implements profile data operations using remote data source
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource dataSource;

  ProfileRepositoryImpl({required this.dataSource});

  /// جلب بيانات الملف الشخصي
  @override
  Future<ProfileUserModel> getMyProfile() async {
    try {
      return await dataSource.getMyProfile();
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  /// تحديث بيانات الملف الشخصي
  @override
  Future<void> updateMyProfile(ProfileUserModel profile) async {
    try {
      await dataSource.updateMyProfile(profile);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}

