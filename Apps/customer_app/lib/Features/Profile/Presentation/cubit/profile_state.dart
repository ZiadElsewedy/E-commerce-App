import '../../Data/Models/profile_user_model.dart';

/// Base class for all profile states
abstract class ProfileState {}

/// Initial state
class ProfileInitial extends ProfileState {}

/// Loading state
class ProfileLoading extends ProfileState {}

/// Profile loaded successfully
class ProfileLoaded extends ProfileState {
  final ProfileUserModel profile;

  ProfileLoaded(this.profile);
}

/// Profile update success
class ProfileUpdateSuccess extends ProfileState {
  final ProfileUserModel profile;
  final String message;

  ProfileUpdateSuccess(this.profile, this.message);
}

/// Error state
class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

