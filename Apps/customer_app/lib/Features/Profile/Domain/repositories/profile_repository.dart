import '../../Data/Models/profile_user_model.dart';

/// ProfileRepository - Interface for profile data operations
/// 
/// Defines the contract for profile data access operations
abstract class ProfileRepository {
  /// جلب بيانات الملف الشخصي
  /// Get current user's profile data
  Future<ProfileUserModel> getMyProfile();
  
  /// تحديث بيانات الملف الشخصي
  /// Update current user's profile data
  Future<void> updateMyProfile(ProfileUserModel profile);
}

