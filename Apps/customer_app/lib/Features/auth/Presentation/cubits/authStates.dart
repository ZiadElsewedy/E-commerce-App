import 'package:ecommerceapp/Features/auth/Domain/Entities/App_User.dart';

/// Base class for all authentication states
abstract class AuthStates {}

/// Initial state - app just started, checking auth status
class AuthInitial extends AuthStates {
  AuthInitial();
}

/// Loading state for authentication operations
class AuthLoading extends AuthStates {
  AuthLoading();
}

/// Authenticated state - user is logged in
class Authenticated extends AuthStates {
  final AppUser user;
  Authenticated(this.user);
}

/// Unauthenticated state - user is not logged in
class Unauthenticated extends AuthStates {
  Unauthenticated();
}

/// Email verification pending state - user needs to verify email
class EmailVerificationPending extends AuthStates {
  final AppUser user;
  EmailVerificationPending(this.user);
}

/// Error state for authentication operations
class AuthError extends AuthStates {
  final String errorMessage;
  AuthError(this.errorMessage);
}

/// Registration success state - user registered successfully
class AuthRegistrationSuccess extends AuthStates {
  final AppUser user;
  final String message;
  AuthRegistrationSuccess(this.user, this.message);
}

/// Password reset email sent state
class AuthPasswordResetSent extends AuthStates {
  final String email;
  AuthPasswordResetSent(this.email);
}