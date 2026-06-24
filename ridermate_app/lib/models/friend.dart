/// Friend model representing a friendship relationship
class Friend {
  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String friendUsername;
  final FriendStatus status;
  final DateTime createdAt;
  final bool isOnline;
  final DateTime? lastSeen;

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendUsername,
    required this.status,
    required this.createdAt,
    this.isOnline = false,
    this.lastSeen,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      friendName: json['friendName'] as String,
      friendUsername: json['friendUsername'] as String,
      status: FriendStatus.values.firstWhere(
        (e) => e.toString() == 'FriendStatus.${json['status']}',
        orElse: () => FriendStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendUsername': friendUsername,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? friendName,
    String? friendUsername,
    FriendStatus? status,
    DateTime? createdAt,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      friendUsername: friendUsername ?? this.friendUsername,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

/// Friend request model
class FriendRequest {
  final String id;
  final String senderId;
  final String senderName;
  final String senderUsername;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderUsername,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderUsername: json['senderUsername'] as String,
      receiverId: json['receiverId'] as String,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.toString() == 'FriendRequestStatus.${json['status']}',
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'receiverId': receiverId,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }
}

/// User model for search results
class UserSearchResult {
  final String id;
  final String name;
  final String username;
  final bool isFriend;
  final bool hasPendingRequest;

  UserSearchResult({
    required this.id,
    required this.name,
    required this.username,
    this.isFriend = false,
    this.hasPendingRequest = false,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      isFriend: json['isFriend'] as bool? ?? false,
      hasPendingRequest: json['hasPendingRequest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'isFriend': isFriend,
      'hasPendingRequest': hasPendingRequest,
    };
  }
}

/// Friend status enum
enum FriendStatus {
  pending,
  accepted,
  blocked,
}

/// Friend request status enum
enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}
