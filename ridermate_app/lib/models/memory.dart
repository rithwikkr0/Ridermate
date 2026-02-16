import 'package:cloud_firestore/cloud_firestore.dart';

enum MemoryVisibility {
  public,
  friends,
  private;

  String get displayName {
    switch (this) {
      case MemoryVisibility.public:
        return 'Public';
      case MemoryVisibility.friends:
        return 'Friends';
      case MemoryVisibility.private:
        return 'Private';
    }
  }

  String get icon {
    switch (this) {
      case MemoryVisibility.public:
        return '🌍';
      case MemoryVisibility.friends:
        return '👥';
      case MemoryVisibility.private:
        return '🔒';
    }
  }

  static MemoryVisibility fromString(String value) {
    return MemoryVisibility.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MemoryVisibility.private,
    );
  }
}

class MemoryModel {
  final String memoryId;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String caption;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final MemoryVisibility visibility;
  final String? rideId;
  final List<String> tags;
  final int viewCount;
  final int likeCount;

  MemoryModel({
    required this.memoryId,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.caption,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.visibility,
    this.rideId,
    this.tags = const [],
    this.viewCount = 0,
    this.likeCount = 0,
  });

  factory MemoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemoryModel(
      memoryId: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      caption: data['caption'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      visibility: MemoryVisibility.fromString(data['visibility'] ?? 'private'),
      rideId: data['rideId'],
      tags: List<String>.from(data['tags'] ?? []),
      viewCount: data['viewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'visibility': visibility.name,
      'rideId': rideId,
      'tags': tags,
      'viewCount': viewCount,
      'likeCount': likeCount,
    };
  }

  MemoryModel copyWith({
    String? memoryId,
    String? userId,
    String? imageUrl,
    String? thumbnailUrl,
    String? caption,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    MemoryVisibility? visibility,
    String? rideId,
    List<String>? tags,
    int? viewCount,
    int? likeCount,
  }) {
    return MemoryModel(
      memoryId: memoryId ?? this.memoryId,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      visibility: visibility ?? this.visibility,
      rideId: rideId ?? this.rideId,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}

class MemoryInteraction {
  final String userId;
  final String memoryId;
  final String action; // 'like' or 'view'
  final DateTime timestamp;

  MemoryInteraction({
    required this.userId,
    required this.memoryId,
    required this.action,
    required this.timestamp,
  });

  factory MemoryInteraction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemoryInteraction(
      userId: data['userId'] ?? '',
      memoryId: data['memoryId'] ?? '',
      action: data['action'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'memoryId': memoryId,
      'action': action,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
