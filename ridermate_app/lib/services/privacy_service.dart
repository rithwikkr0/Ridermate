import '../models/privacy_settings.dart';
import 'user_profile_service.dart';

class PrivacyService {
  final UserProfileService _userProfileService = UserProfileService();

  // Check if a user can view another user's profile
  Future<bool> canViewProfile({
    required String targetUserId,
    String? requestingUserId,
  }) async {
    try {
      final privacy = await _userProfileService.getPrivacySettings(targetUserId);
      if (privacy == null) return true; // Default to public if no settings

      return privacy.canViewProfile(requestingUserId);
    } catch (e) {
      return false;
    }
  }

  // Check if a user can view another user's location
  Future<bool> canViewLocation({
    required String targetUserId,
    String? requestingUserId,
  }) async {
    try {
      final privacy = await _userProfileService.getPrivacySettings(targetUserId);
      if (privacy == null) return false; // Default to private for location

      return privacy.canViewLocation(requestingUserId);
    } catch (e) {
      return false;
    }
  }

  // Check if a user is blocked
  Future<bool> isUserBlocked({
    required String userId,
    required String potentialBlockedUserId,
  }) async {
    try {
      final privacy = await _userProfileService.getPrivacySettings(userId);
      if (privacy == null) return false;

      return privacy.blockList.contains(potentialBlockedUserId);
    } catch (e) {
      return false;
    }
  }

  // Block a user
  Future<void> blockUser({
    required String userId,
    required String userToBlockId,
  }) async {
    try {
      final privacy = await _userProfileService.getPrivacySettings(userId);
      if (privacy == null) return;

      if (!privacy.blockList.contains(userToBlockId)) {
        final updatedBlockList = [...privacy.blockList, userToBlockId];
        await _userProfileService.updatePrivacySettings(
          userId,
          {'blockList': updatedBlockList},
        );
      }
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Unblock a user
  Future<void> unblockUser({
    required String userId,
    required String userToUnblockId,
  }) async {
    try {
      final privacy = await _userProfileService.getPrivacySettings(userId);
      if (privacy == null) return;

      final updatedBlockList = privacy.blockList.where((id) => id != userToUnblockId).toList();
      await _userProfileService.updatePrivacySettings(
        userId,
        {'blockList': updatedBlockList},
      );
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  // Add user to location sharing list
  Future<void> shareLocationWith({
    required String userId,
    required String userToShareWithId,
  }) async {
    try {
      final privacy = await _userProfileService.getPrivacySettings(userId);
      if (privacy == null) return;

      if (!privacy.locationSharingWith.contains(userToShareWithId)) {
        final updatedList = [...privacy.locationSharingWith, userToShareWithId];
        await _userProfileService.updatePrivacySettings(
          userId,
          {'locationSharingWith': updatedList},
        );
      }
    } catch (e) {
      throw Exception('Failed to share location: $e');
    }
  }

  // Remove user from location sharing list
  Future<void> stopSharingLocationWith({
    required String userId,
    required String userToStopSharingWithId,
  }) async {
    try {
      final privacy = await _userProfileService.getPrivacySettings(userId);
      if (privacy == null) return;

      final updatedList = privacy.locationSharingWith
          .where((id) => id != userToStopSharingWithId)
          .toList();
      await _userProfileService.updatePrivacySettings(
        userId,
        {'locationSharingWith': updatedList},
      );
    } catch (e) {
      throw Exception('Failed to stop sharing location: $e');
    }
  }

  // Get filtered user data based on privacy settings
  Future<Map<String, dynamic>?> getFilteredUserData({
    required String targetUserId,
    String? requestingUserId,
  }) async {
    try {
      final canView = await canViewProfile(
        targetUserId: targetUserId,
        requestingUserId: requestingUserId,
      );

      if (!canView) return null;

      final user = await _userProfileService.getUserProfile(targetUserId);
      if (user == null) return null;

      final privacy = await _userProfileService.getPrivacySettings(targetUserId);
      
      Map<String, dynamic> filteredData = {
        'userId': user.userId,
        'name': user.name,
        'profilePhoto': user.profilePhoto,
      };

      // Add more data based on privacy level
      if (privacy?.profileVisibility == 'public' || requestingUserId == targetUserId) {
        filteredData.addAll({
          'bio': user.bio,
          'totalRides': user.totalRides,
          'totalPoints': user.totalPoints,
          'safetyScore': user.safetyScore,
        });
      }

      // Only show phone number to owner
      if (requestingUserId == targetUserId) {
        filteredData.addAll({
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'totalDistance': user.totalDistance,
          'currentStreak': user.currentStreak,
          'dateOfJoined': user.dateOfJoined,
        });
      }

      return filteredData;
    } catch (e) {
      return null;
    }
  }
}
