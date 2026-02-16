/// Live location model for real-time location sharing
class LiveLocation {
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final DateTime timestamp;
  final bool isSharing;

  LiveLocation({
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    this.accuracy,
    required this.timestamp,
    this.isSharing = true,
  });

  factory LiveLocation.fromJson(Map<String, dynamic> json) {
    return LiveLocation(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading:
          json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSharing: json['isSharing'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'isSharing': isSharing,
    };
  }

  LiveLocation copyWith({
    String? userId,
    String? userName,
    double? latitude,
    double? longitude,
    double? speed,
    double? heading,
    double? accuracy,
    DateTime? timestamp,
    bool? isSharing,
  }) {
    return LiveLocation(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  /// Check if location data is stale (older than 30 seconds)
  bool get isStale {
    return DateTime.now().difference(timestamp).inSeconds > 30;
  }

  /// Get formatted speed string
  String get formattedSpeed {
    if (speed == null) return '0.0 km/h';
    return '${speed!.toStringAsFixed(1)} km/h';
  }

  /// Get formatted accuracy string
  String get formattedAccuracy {
    if (accuracy == null) return 'Unknown';
    return '±${accuracy!.toStringAsFixed(0)}m';
  }
}

/// Location update event for real-time updates
class LocationUpdate {
  final String userId;
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  LocationUpdate({
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      userId: json['userId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading:
          json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Location sharing settings
class LocationSharingSettings {
  final bool enabled;
  final LocationPrivacy privacy;
  final List<String> allowedFriends;
  final bool shareSpeed;
  final bool shareHeading;

  LocationSharingSettings({
    this.enabled = false,
    this.privacy = LocationPrivacy.friendsOnly,
    this.allowedFriends = const [],
    this.shareSpeed = true,
    this.shareHeading = true,
  });

  factory LocationSharingSettings.fromJson(Map<String, dynamic> json) {
    return LocationSharingSettings(
      enabled: json['enabled'] as bool? ?? false,
      privacy: LocationPrivacy.values.firstWhere(
        (e) => e.toString() == 'LocationPrivacy.${json['privacy']}',
        orElse: () => LocationPrivacy.friendsOnly,
      ),
      allowedFriends: (json['allowedFriends'] as List<dynamic>?)
              ?.map((f) => f as String)
              .toList() ??
          [],
      shareSpeed: json['shareSpeed'] as bool? ?? true,
      shareHeading: json['shareHeading'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'privacy': privacy.toString().split('.').last,
      'allowedFriends': allowedFriends,
      'shareSpeed': shareSpeed,
      'shareHeading': shareHeading,
    };
  }

  LocationSharingSettings copyWith({
    bool? enabled,
    LocationPrivacy? privacy,
    List<String>? allowedFriends,
    bool? shareSpeed,
    bool? shareHeading,
  }) {
    return LocationSharingSettings(
      enabled: enabled ?? this.enabled,
      privacy: privacy ?? this.privacy,
      allowedFriends: allowedFriends ?? this.allowedFriends,
      shareSpeed: shareSpeed ?? this.shareSpeed,
      shareHeading: shareHeading ?? this.shareHeading,
    );
  }
}

/// Location privacy options
enum LocationPrivacy {
  none,
  friendsOnly,
  selectedFriends,
  public,
}
