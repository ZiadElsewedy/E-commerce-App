import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerceapp/Features/auth/Domain/Entities/App_User.dart';
import 'package:ecommerceapp/Features/auth/Domain/repo/Auth_repo.dart';
import 'authStates.dart';


class AuthCubit extends Cubit<AuthStates> {
  /// Repository for authentication operations
  final AuthRepository authRepository;

  /// Constructor - initializes with AuthInitial state
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  /// Checks if user is already logged in on app start
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      
      if (user != null) {
        // Check if email is verified
        final isVerified = await authRepository.isEmailVerified();
        
        if (isVerified) {
          emit(Authenticated(user));
        } else {
          emit(EmailVerificationPending(user));
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }


  Future<void> login({required String email, required String password, }) async {
    // Validate input
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError('Email and password cannot be empty'));
      return;
    }

    emit(AuthLoading());
    try {
      final user = await authRepository.loginwithEmailAndPassword(email, password);

      // Check if email is verified
      final isVerified = await authRepository.isEmailVerified();

      if (isVerified) {
        emit(Authenticated(user));
      } else {
        emit(EmailVerificationPending(user));
      }
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    // Validate input
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError('Email and password cannot be empty'));
      return;
    }

    if (password.length < 6) {
      emit(AuthError('Password must be at least 6 characters'));
      return;
    }

    emit(AuthLoading());
    try {
      final user = await authRepository.registerwithEmailAndPassword(email, password);
      
      // Create updated user with name and phone if provided
      final updatedUser = user.copyWith(name: name, phone: phone);
      
      // Save user data to Firestore
      await (authRepository as dynamic).saveUserData(updatedUser);
      
      emit(AuthRegistrationSuccess(
        updatedUser,
        'Registration successful! Please check your email to verify your account.',
      ));
      
      // Transition to email verification pending state
      emit(EmailVerificationPending(updatedUser));
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      emit(AuthError('Email cannot be empty'));
      return;
    }

    emit(AuthLoading());
    try {
      await authRepository.sendPasswordResetEmail(email);
      emit(AuthPasswordResetSent(email));
      
      // Return to unauthenticated state after showing success
      Future.delayed(const Duration(seconds: 2), () {
        emit(Unauthenticated());
      });
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }


  Future<bool> checkEmailVerification() async {
    try {
      final isVerified = await authRepository.isEmailVerified();
      
      if (isVerified) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        }
      }
      
      return isVerified;
    } catch (e) {
      return false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await authRepository.resendVerificationEmail();
      // Keep the current state (EmailVerificationPending)
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithGoogle();
      
      if (user != null) {
        // Google users are automatically verified, no email verification needed
        emit(Authenticated(user));
      } else {
        // User cancelled the sign-in
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }


  Future<void> deleteAccount() async {
    emit(AuthLoading());
    try {
      await authRepository.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }


  AppUser? getCurrentUser() {
    final currentState = state;
    if (currentState is Authenticated) {
      return currentState.user;
    }
    return null;
  }


  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Firebase Auth error messages
    if (errorString.contains('user-not-found')) {
      return 'No user found with this email';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (errorString.contains('email-already-in-use')) {
      return 'An account already exists with this email';
    } else if (errorString.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (errorString.contains('weak-password')) {
      return 'Password is too weak';
    } else if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    } else if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    } else if (errorString.contains('email not verified')) {
      return 'Please verify your email before logging in';
    }
    
    // Default error message
    return error.toString().replaceAll('Exception: ', '');
  }
}

