import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  final String userId;
  final bool emailNotifications;
  final bool pushNotifications;
  final String notificationFrequency; // 'realtime', 'daily', 'weekly'
  final List<String> notificationTypes; // ['rides', 'friends', 'memories', 'achievements']
  final String theme; // 'light', 'dark', 'auto'
  final String language;
  final String units; // 'km', 'miles'
  final String preferredMapStyle; // 'standard', 'satellite', 'hybrid'

  UserSettings({
    required this.userId,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.notificationFrequency = 'daily',
    this.notificationTypes = const ['rides', 'friends', 'memories', 'achievements'],
    this.theme = 'dark',
    this.language = 'en',
    this.units = 'km',
    this.preferredMapStyle = 'standard',
  });

  factory UserSettings.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserSettings(
      userId: doc.id,
      emailNotifications: data['emailNotifications'] ?? true,
      pushNotifications: data['pushNotifications'] ?? true,
      notificationFrequency: data['notificationFrequency'] ?? 'daily',
      notificationTypes: List<String>.from(data['notificationTypes'] ?? ['rides', 'friends', 'memories', 'achievements']),
      theme: data['theme'] ?? 'dark',
      language: data['language'] ?? 'en',
      units: data['units'] ?? 'km',
      preferredMapStyle: data['preferredMapStyle'] ?? 'standard',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'notificationFrequency': notificationFrequency,
      'notificationTypes': notificationTypes,
      'theme': theme,
      'language': language,
      'units': units,
      'preferredMapStyle': preferredMapStyle,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  UserSettings copyWith({
    String? userId,
    bool? emailNotifications,
    bool? pushNotifications,
    String? notificationFrequency,
    List<String>? notificationTypes,
    String? theme,
    String? language,
    String? units,
    String? preferredMapStyle,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      units: units ?? this.units,
      preferredMapStyle: preferredMapStyle ?? this.preferredMapStyle,
    );
  }
}
