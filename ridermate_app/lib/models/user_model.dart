import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String email;
  final String name;
  final String? profilePhoto;
  final String? bio;
  final String? phoneNumber;
  final DateTime dateOfJoined;
  final String privacyMode; // 'public', 'friends-only', 'private'
  final double totalDistance;
  final int totalRides;
  final int totalPoints;
  final double safetyScore;
  final int currentStreak;
  final String preferredLanguage;
  final Map<String, dynamic> notificationSettings;
  final DateTime? lastLoginAt;
  final DateTime? updatedAt;

  User({
    required this.userId,
    required this.email,
    required this.name,
    this.profilePhoto,
    this.bio,
    this.phoneNumber,
    required this.dateOfJoined,
    this.privacyMode = 'public',
    this.totalDistance = 0.0,
    this.totalRides = 0,
    this.totalPoints = 0,
    this.safetyScore = 100.0,
    this.currentStreak = 0,
    this.preferredLanguage = 'en',
    this.notificationSettings = const {
      'emailNotifications': true,
      'pushNotifications': true,
      'notificationFrequency': 'daily',
    },
    this.lastLoginAt,
    this.updatedAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      userId: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profilePhoto: data['profilePhoto'],
      bio: data['bio'],
      phoneNumber: data['phoneNumber'],
      dateOfJoined: (data['dateOfJoined'] as Timestamp?)?.toDate() ?? DateTime.now(),
      privacyMode: data['privacyMode'] ?? 'public',
      totalDistance: (data['totalDistance'] ?? 0.0).toDouble(),
      totalRides: data['totalRides'] ?? 0,
      totalPoints: data['totalPoints'] ?? 0,
      safetyScore: (data['safetyScore'] ?? 100.0).toDouble(),
      currentStreak: data['currentStreak'] ?? 0,
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      notificationSettings: data['notificationSettings'] ?? {
        'emailNotifications': true,
        'pushNotifications': true,
        'notificationFrequency': 'daily',
      },
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'profilePhoto': profilePhoto,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'dateOfJoined': Timestamp.fromDate(dateOfJoined),
      'privacyMode': privacyMode,
      'totalDistance': totalDistance,
      'totalRides': totalRides,
      'totalPoints': totalPoints,
      'safetyScore': safetyScore,
      'currentStreak': currentStreak,
      'preferredLanguage': preferredLanguage,
      'notificationSettings': notificationSettings,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  User copyWith({
    String? userId,
    String? email,
    String? name,
    String? profilePhoto,
    String? bio,
    String? phoneNumber,
    DateTime? dateOfJoined,
    String? privacyMode,
    double? totalDistance,
    int? totalRides,
    int? totalPoints,
    double? safetyScore,
    int? currentStreak,
    String? preferredLanguage,
    Map<String, dynamic>? notificationSettings,
    DateTime? lastLoginAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfJoined: dateOfJoined ?? this.dateOfJoined,
      privacyMode: privacyMode ?? this.privacyMode,
      totalDistance: totalDistance ?? this.totalDistance,
      totalRides: totalRides ?? this.totalRides,
      totalPoints: totalPoints ?? this.totalPoints,
      safetyScore: safetyScore ?? this.safetyScore,
      currentStreak: currentStreak ?? this.currentStreak,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
