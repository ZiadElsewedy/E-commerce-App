import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Domain/repositories/profile_repository.dart';
import '../../Data/Models/profile_user_model.dart';
import 'profile_state.dart';

/// ProfileCubit - Manages profile state and operations
/// 
/// Handles profile data fetching and updates
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(ProfileInitial());

  /// جلب بيانات الملف الشخصي
  /// Fetches current user's profile data
  Future<void> getMyProfile() async {
    try {
      emit(ProfileLoading());
      final profile = await repository.getMyProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(_getErrorMessage(e)));
    }
  }

  /// تحديث بيانات الملف الشخصي
  /// Updates current user's profile data
  Future<void> updateMyProfile(ProfileUserModel profile) async {
    try {
      emit(ProfileLoading());
      await repository.updateMyProfile(profile);
      emit(ProfileUpdateSuccess(profile, 'Profile updated successfully'));
      
      // After showing success, emit loaded state with updated profile
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          emit(ProfileLoaded(profile));
        }
      });
    } catch (e) {
      emit(ProfileError(_getErrorMessage(e)));
    }
  }

  /// الحصول على الملف الشخصي الحالي من الحالة
  /// Gets current profile from state
  ProfileUserModel? getCurrentProfile() {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      return currentState.profile;
    } else if (currentState is ProfileUpdateSuccess) {
      return currentState.profile;
    }
    return null;
  }

  /// تحويل الخطأ إلى رسالة مفهومة
  /// Converts error to user-friendly message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('no user logged in')) {
      return 'You must be logged in to view profile';
    } else if (errorString.contains('profile not found')) {
      return 'Profile data not found';
    } else if (errorString.contains('network')) {
      return 'Network error. Please check your connection';
    } else if (errorString.contains('permission')) {
      return 'Permission denied';
    }
    
    return error.toString().replaceAll('Exception: ', '');
  }
}

