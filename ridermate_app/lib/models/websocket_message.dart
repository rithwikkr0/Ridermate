/// WebSocket message model for real-time communication
class WebSocketMessage {
  final WebSocketMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? userId;

  WebSocketMessage({
    required this.type,
    required this.data,
    DateTime? timestamp,
    this.userId,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: WebSocketMessageType.values.firstWhere(
        (e) => e.toString() == 'WebSocketMessageType.${json['type']}',
        orElse: () => WebSocketMessageType.unknown,
      ),
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  /// Factory constructors for specific message types
  factory WebSocketMessage.locationUpdate({
    required String userId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  }) {
    return WebSocketMessage(
      type: WebSocketMessageType.locationUpdate,
      userId: userId,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'heading': heading,
      },
    );
  }

  factory WebSocketMessage.friendPresence({
    required String userId,
    required bool isOnline,
  }) {
    return WebSocketMessage(
      type: WebSocketMessageType.friendPresence,
      userId: userId,
      data: {
        'isOnline': isOnline,
      },
    );
  }

  factory WebSocketMessage.chatMessage({
    required String roomId,
    required String senderId,
    required String message,
  }) {
    return WebSocketMessage(
      type: WebSocketMessageType.chatMessage,
      userId: senderId,
      data: {
        'roomId': roomId,
        'message': message,
      },
    );
  }

  factory WebSocketMessage.roomUpdate({
    required String roomId,
    required Map<String, dynamic> roomData,
  }) {
    return WebSocketMessage(
      type: WebSocketMessageType.roomUpdate,
      data: {
        'roomId': roomId,
        ...roomData,
      },
    );
  }

  factory WebSocketMessage.friendRequest({
    required String requestId,
    required String senderId,
    required String senderName,
  }) {
    return WebSocketMessage(
      type: WebSocketMessageType.friendRequest,
      userId: senderId,
      data: {
        'requestId': requestId,
        'senderName': senderName,
      },
    );
  }

  factory WebSocketMessage.error({
    required String errorMessage,
    String? errorCode,
  }) {
    return WebSocketMessage(
      type: WebSocketMessageType.error,
      data: {
        'message': errorMessage,
        'code': errorCode,
      },
    );
  }
}

/// WebSocket message types
enum WebSocketMessageType {
  // Connection events
  connected,
  disconnected,
  error,
  
  // Location events
  locationUpdate,
  locationShareStart,
  locationShareStop,
  
  // Friend events
  friendPresence,
  friendRequest,
  friendAccepted,
  friendRemoved,
  
  // Room events
  roomUpdate,
  roomJoined,
  roomLeft,
  participantJoined,
  participantLeft,
  
  // Chat events
  chatMessage,
  
  // System events
  ping,
  pong,
  
  // Unknown
  unknown,
}

/// WebSocket connection state
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket connection event
class WebSocketConnectionEvent {
  final WebSocketState state;
  final String? errorMessage;
  final DateTime timestamp;

  WebSocketConnectionEvent({
    required this.state,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isConnected => state == WebSocketState.connected;
  bool get isDisconnected => state == WebSocketState.disconnected;
  bool get hasError => state == WebSocketState.error;
}
