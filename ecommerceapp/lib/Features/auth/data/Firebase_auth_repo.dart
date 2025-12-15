import 'package:ecommerceapp/Features/auth/Domain/Entities/App_User.dart';
import 'package:ecommerceapp/Features/auth/Domain/repo/Auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account');
    }

  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      
      // Try to get user data from Firestore
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          return AppUser(
            userId: user.uid,
            email: user.email!,
            name: data['name'] as String?,
            phone: data['phone'] as String?,
          );
        }
      } catch (firestoreError) {
        print('Firestore error (non-critical): $firestoreError');
      }
      
      // Fallback to basic user info if Firestore fails
      AppUser appUser = AppUser(
        userId: user.uid,
        email: user.email!,
      );
      return appUser;
    } catch (e) {
      throw Exception('Failed to get current user');
    }
      
  }

  @override
  Future<AppUser> loginwithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;

    if (user == null) {
      throw Exception('Login failed');
    }

    // Try to get user data from Firestore
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return AppUser(
          userId: user.uid,
          email: user.email!,
          name: data['name'] as String?,
          phone: data['phone'] as String?,
        );
      }
    } catch (firestoreError) {
      print('Firestore error (non-critical): $firestoreError');
    }

    // Return basic user if Firestore data not found
    return AppUser(
      userId: user.uid,
      email: user.email!,
    );

  } catch (e) {
    throw Exception(e.toString());
  }
}


  @override
Future<AppUser> registerwithEmailAndPassword(String email, String password) async {
  try {
    // 1️⃣ Register user - Firebase will automatically check if email exists
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    // 2️⃣ Send verification email
    await userCredential.user?.sendEmailVerification();

    // 3️⃣ Create AppUser object (name will be updated by AuthCubit)
    AppUser user = AppUser(
      userId: userCredential.user!.uid,
      email: email,
    );

    return user;

  } on FirebaseAuthException catch (e) {
    // Handle specific Firebase Auth errors
    if (e.code == 'email-already-in-use') {
      throw Exception('This email is already registered. Please login instead.');
    } else if (e.code == 'weak-password') {
      throw Exception('Password is too weak. Please use a stronger password.');
    } else if (e.code == 'invalid-email') {
      throw Exception('Invalid email address format.');
    } else if (e.code == 'operation-not-allowed') {
      throw Exception('Email/password accounts are not enabled.');
    } else {
      throw Exception('Registration failed: ${e.message}');
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

  /// Save user data to Firestore (only if not exists or update if needed)
  Future<void> saveUserData(AppUser user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.userId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        // New user - create with all fields
        await docRef.set({
          'email': user.email,
          'name': user.name,
          'phone': user.phone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Existing user - only update name and phone if provided
        Map<String, dynamic> updates = {
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        if (user.name != null && user.name!.isNotEmpty) {
          updates['name'] = user.name;
        }
        if (user.phone != null && user.phone!.isNotEmpty) {
          updates['phone'] = user.phone;
        }
        
        await docRef.update(updates);
      }
    } catch (e) {
      print('Failed to save user data: $e');
      // Don't throw - this is non-critical
    }
  }


  @override
  Future<AppUser> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return AppUser(
        userId: '',
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to reset password');
    }
  }

  

  @override
  Future<AppUser> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return AppUser(
        userId: '',
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to send password reset email');
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await firebaseAuth.signOut();
      
      // Sign out from Google to allow account selection next time
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      } catch (googleError) {
        // Google sign-out failed, but continue with Firebase logout
        print('Google sign-out error (non-critical): $googleError');
      }
    } catch (e) {
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }
  
  @override
Future<bool> isEmailVerified() async {
  try {
    User? user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User not found');
    }

    // ⭐ أهم خطوة.. تحديث بيانات المستخدم من السيرفر
    await user.reload();
    user = firebaseAuth.currentUser;

    return user?.emailVerified ?? false;
    } catch (e) {
      throw Exception('Failed to check if email is verified');
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      User? user = firebaseAuth.currentUser;

      if (user == null) {
        throw Exception('User not found');
      }

      if (user.emailVerified) {
        throw Exception('Email is already verified');
      }

      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to resend verification email');
    }
  }
  
  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow (will show account picker)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential with proper null handling
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      
      // Sign in to Firebase with the Google credential
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      
      // Check if user already exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // New Google user - save to Firestore
        final appUser = AppUser(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: googleUser.displayName,
        );
        await saveUserData(appUser);
        return appUser;
      } else {
        // Existing user - get from Firestore
        final data = userDoc.data()!;
        return AppUser(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: data['name'] as String?,
          phone: data['phone'] as String?,
        );
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }
}
