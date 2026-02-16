import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacySettings {
  final String userId;
  final String profileVisibility; // 'public', 'friends', 'private'
  final String locationSharing; // 'everyone', 'friends', 'none'
  final String memoryVisibilityDefault; // 'public', 'friends', 'private'
  final String friendRequestSettings; // 'everyone', 'friends-of-friends', 'none'
  final List<String> blockList;
  final List<String> locationSharingWith; // Specific user IDs

  PrivacySettings({
    required this.userId,
    this.profileVisibility = 'public',
    this.locationSharing = 'friends',
    this.memoryVisibilityDefault = 'public',
    this.friendRequestSettings = 'everyone',
    this.blockList = const [],
    this.locationSharingWith = const [],
  });

  factory PrivacySettings.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PrivacySettings(
      userId: doc.id,
      profileVisibility: data['profileVisibility'] ?? 'public',
      locationSharing: data['locationSharing'] ?? 'friends',
      memoryVisibilityDefault: data['memoryVisibilityDefault'] ?? 'public',
      friendRequestSettings: data['friendRequestSettings'] ?? 'everyone',
      blockList: List<String>.from(data['blockList'] ?? []),
      locationSharingWith: List<String>.from(data['locationSharingWith'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'profileVisibility': profileVisibility,
      'locationSharing': locationSharing,
      'memoryVisibilityDefault': memoryVisibilityDefault,
      'friendRequestSettings': friendRequestSettings,
      'blockList': blockList,
      'locationSharingWith': locationSharingWith,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  PrivacySettings copyWith({
    String? userId,
    String? profileVisibility,
    String? locationSharing,
    String? memoryVisibilityDefault,
    String? friendRequestSettings,
    List<String>? blockList,
    List<String>? locationSharingWith,
  }) {
    return PrivacySettings(
      userId: userId ?? this.userId,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      locationSharing: locationSharing ?? this.locationSharing,
      memoryVisibilityDefault: memoryVisibilityDefault ?? this.memoryVisibilityDefault,
      friendRequestSettings: friendRequestSettings ?? this.friendRequestSettings,
      blockList: blockList ?? this.blockList,
      locationSharingWith: locationSharingWith ?? this.locationSharingWith,
    );
  }

  bool canViewProfile(String? requestingUserId) {
    if (requestingUserId == null) return profileVisibility == 'public';
    if (requestingUserId == userId) return true;
    if (blockList.contains(requestingUserId)) return false;
    
    if (profileVisibility == 'public') return true;
    if (profileVisibility == 'private') return false;
    // For 'friends' visibility, would need to check friendship status
    return false;
  }

  bool canViewLocation(String? requestingUserId) {
    if (requestingUserId == null) return false;
    if (requestingUserId == userId) return true;
    if (blockList.contains(requestingUserId)) return false;
    
    if (locationSharing == 'none') return false;
    if (locationSharing == 'everyone') return true;
    if (locationSharingWith.contains(requestingUserId)) return true;
    // For 'friends' sharing, would need to check friendship status
    return false;
  }
}
