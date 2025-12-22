import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/profile_user_model.dart';

/// ProfileRemoteDataSource - Handles profile data operations with Firebase
/// 
/// Manages all remote data operations for user profile using Firestore
class ProfileRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// جلب بيانات الملف الشخصي من Firestore
  /// Fetches current user's profile data from Firestore
  /// Creates a basic profile if document doesn't exist
  Future<ProfileUserModel> getMyProfile() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!docSnapshot.exists) {
        // Create a basic profile from Firebase Auth data
        final basicProfile = ProfileUserModel(
          userId: currentUser.uid,
          email: currentUser.email ?? '',
          name: currentUser.displayName,
          phone: currentUser.phoneNumber,
        );
        
        // Create the document in Firestore with basic info
        try {
          await _firestore.collection('users').doc(currentUser.uid).set({
            'user_id': currentUser.uid,
            'email': currentUser.email ?? '',
            'name': currentUser.displayName,
            'phone': currentUser.phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          // If Firestore write fails, still return the basic profile
          // This allows the user to see their profile even if write fails
        }
        
        return basicProfile;
      }

      final data = docSnapshot.data()!;
      // Ensure user_id is included in the data
      data['user_id'] = currentUser.uid;
      
      return ProfileUserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  /// تحديث بيانات الملف الشخصي في Firestore
  /// Updates current user's profile data in Firestore
  /// Creates document if it doesn't exist
  Future<void> updateMyProfile(ProfileUserModel profile) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Prepare update data (include user_id and email for document creation)
      final updateData = {
        'user_id': profile.userId,
        'email': profile.email,
        'name': profile.name,
        'phone': profile.phone,
        'photo_url': profile.photoUrl,
        'language': profile.language,
        'theme': profile.theme,
        'notification_enabled': profile.notificationEnabled,
        'orders_count': profile.ordersCount,
        'wishlist_count': profile.wishlistCount,
        'addresses_count': profile.addressesCount,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove null values to avoid overwriting existing data with null
      updateData.removeWhere((key, value) => value == null);

      // Use set with merge to create document if it doesn't exist, or update if it does
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}

