import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/user_settings.dart';
import '../models/privacy_settings.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create user profile document
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      final user = User(
        userId: userId,
        email: email,
        name: name,
        profilePhoto: photoUrl,
        dateOfJoined: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(user.toFirestore());

      // Create default settings
      await createDefaultSettings(userId);
      
      // Create default privacy settings
      await createDefaultPrivacySettings(userId);
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile
  Future<User?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update last login time
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      // Update user profile with new photo URL
      await updateUserProfile(userId, {'profilePhoto': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  // Delete profile photo
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId.jpg');
      await ref.delete();
      
      // Update user profile to remove photo URL
      await updateUserProfile(userId, {'profilePhoto': null});
    } catch (e) {
      // Photo may not exist, that's okay
      await updateUserProfile(userId, {'profilePhoto': null});
    }
  }

  // Create default user settings
  Future<void> createDefaultSettings(String userId) async {
    try {
      final settings = UserSettings(userId: userId);
      await _firestore.collection('user_settings').doc(userId).set(settings.toFirestore());
    } catch (e) {
      throw Exception('Failed to create default settings: $e');
    }
  }

  // Get user settings
  Future<UserSettings?> getUserSettings(String userId) async {
    try {
      final doc = await _firestore.collection('user_settings').doc(userId).get();
      if (doc.exists) {
        return UserSettings.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user settings: $e');
    }
  }

  // Update user settings
  Future<void> updateUserSettings(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('user_settings').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  // Create default privacy settings
  Future<void> createDefaultPrivacySettings(String userId) async {
    try {
      final privacy = PrivacySettings(userId: userId);
      await _firestore.collection('user_privacy').doc(userId).set(privacy.toFirestore());
    } catch (e) {
      throw Exception('Failed to create default privacy settings: $e');
    }
  }

  // Get privacy settings
  Future<PrivacySettings?> getPrivacySettings(String userId) async {
    try {
      final doc = await _firestore.collection('user_privacy').doc(userId).get();
      if (doc.exists) {
        return PrivacySettings.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get privacy settings: $e');
    }
  }

  // Update privacy settings
  Future<void> updatePrivacySettings(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('user_privacy').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update privacy settings: $e');
    }
  }

  // Update user stats (for ride completion, etc.)
  Future<void> updateUserStats({
    required String userId,
    double? distanceToAdd,
    int? ridesToAdd,
    int? pointsToAdd,
    double? newSafetyScore,
    int? newStreak,
  }) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return;

      final user = User.fromFirestore(doc);
      
      Map<String, dynamic> updates = {};
      
      if (distanceToAdd != null) {
        updates['totalDistance'] = user.totalDistance + distanceToAdd;
      }
      if (ridesToAdd != null) {
        updates['totalRides'] = user.totalRides + ridesToAdd;
      }
      if (pointsToAdd != null) {
        updates['totalPoints'] = user.totalPoints + pointsToAdd;
      }
      if (newSafetyScore != null) {
        updates['safetyScore'] = newSafetyScore;
      }
      if (newStreak != null) {
        updates['currentStreak'] = newStreak;
      }

      if (updates.isNotEmpty) {
        await updateUserProfile(userId, updates);
      }
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }

  // Delete user account and all related data
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete user settings
      await _firestore.collection('user_settings').doc(userId).delete();
      
      // Delete privacy settings
      await _firestore.collection('user_privacy').doc(userId).delete();
      
      // Delete profile photo from storage
      try {
        final ref = _storage.ref().child('profile_photos/$userId.jpg');
        await ref.delete();
      } catch (e) {
        // Photo may not exist
      }
    } catch (e) {
      throw Exception('Failed to delete user account: $e');
    }
  }

  // Stream user profile updates
  Stream<User?> streamUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    });
  }

  // Stream user settings updates
  Stream<UserSettings?> streamUserSettings(String userId) {
    return _firestore.collection('user_settings').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserSettings.fromFirestore(doc);
      }
      return null;
    });
  }

  // Stream privacy settings updates
  Stream<PrivacySettings?> streamPrivacySettings(String userId) {
    return _firestore.collection('user_privacy').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return PrivacySettings.fromFirestore(doc);
      }
      return null;
    });
  }
}
