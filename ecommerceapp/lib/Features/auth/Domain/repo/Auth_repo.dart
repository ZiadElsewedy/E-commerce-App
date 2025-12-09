// outlines the interface for the authentication repository
import 'package:ecommerceapp/Features/auth/Domain/Entities/App_User.dart';

abstract class AuthRepository {
  Future<AppUser> loginwithEmailAndPassword(String email, String password);
  Future<AppUser> registerwithEmailAndPassword(String email, String password);
  Future<void> logout();
  Future<AppUser> resetPassword(String email);
  Future<AppUser> sendPasswordResetEmail(String email);
  Future<AppUser?> getCurrentUser();
  Future<void> deleteAccount();
  Future<bool> isEmailVerified();
}
