/// Ride room model for group rides
class RideRoom {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final List<RoomParticipant> participants;
  final bool isPublic;
  final String? inviteCode;
  final int maxCapacity;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final RoomStatus status;

  RideRoom({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.participants,
    required this.isPublic,
    this.inviteCode,
    this.maxCapacity = 10,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.status = RoomStatus.waiting,
  });

  factory RideRoom.fromJson(Map<String, dynamic> json) {
    return RideRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => RoomParticipant.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      isPublic: json['isPublic'] as bool,
      inviteCode: json['inviteCode'] as String?,
      maxCapacity: json['maxCapacity'] as int? ?? 10,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      status: RoomStatus.values.firstWhere(
        (e) => e.toString() == 'RoomStatus.${json['status']}',
        orElse: () => RoomStatus.waiting,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostId': hostId,
      'hostName': hostName,
      'participants': participants.map((p) => p.toJson()).toList(),
      'isPublic': isPublic,
      'inviteCode': inviteCode,
      'maxCapacity': maxCapacity,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  bool get isFull => participants.length >= maxCapacity;
  bool get isActive => status == RoomStatus.active;
  int get participantCount => participants.length;
}

/// Room participant model
class RoomParticipant {
  final String userId;
  final String name;
  final String username;
  final DateTime joinedAt;
  final bool isHost;
  final bool isReady;

  RoomParticipant({
    required this.userId,
    required this.name,
    required this.username,
    required this.joinedAt,
    this.isHost = false,
    this.isReady = false,
  });

  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    return RoomParticipant(
      userId: json['userId'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isHost: json['isHost'] as bool? ?? false,
      isReady: json['isReady'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'username': username,
      'joinedAt': joinedAt.toIso8601String(),
      'isHost': isHost,
      'isReady': isReady,
    };
  }

  RoomParticipant copyWith({
    String? userId,
    String? name,
    String? username,
    DateTime? joinedAt,
    bool? isHost,
    bool? isReady,
  }) {
    return RoomParticipant(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      username: username ?? this.username,
      joinedAt: joinedAt ?? this.joinedAt,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
    );
  }
}

/// Chat message model for room chat
class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }
}

/// Room status enum
enum RoomStatus {
  waiting,
  active,
  finished,
  cancelled,
}

/// Message type enum
enum MessageType {
  text,
  system,
  location,
}
