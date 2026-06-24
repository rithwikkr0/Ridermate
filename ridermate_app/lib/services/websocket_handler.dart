import 'dart:async';
import 'dart:convert';
import '../models/websocket_message.dart';
import '../models/live_location.dart';
import '../models/ride_room.dart';

/// WebSocket handler for real-time communication
/// In production, this would use socket_io_client or web_socket_channel
class WebSocketHandler {
  static const String _wsUrl = 'wss://api.ridermate.com/ws';
  
  // Connection state
  WebSocketState _state = WebSocketState.disconnected;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  
  // Stream controllers
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _connectionController = StreamController<WebSocketConnectionEvent>.broadcast();
  
  Stream<WebSocketMessage> get messageStream => _messageController.stream;
  Stream<WebSocketConnectionEvent> get connectionStream => _connectionController.stream;
  
  String? _userId;
  
  /// Connect to WebSocket server
  Future<void> connect(String userId) async {
    if (_state == WebSocketState.connected || _state == WebSocketState.connecting) {
      return;
    }
    
    _userId = userId;
    _state = WebSocketState.connecting;
    _notifyConnectionState();
    
    try {
      // TODO: Replace with actual WebSocket connection
      // final channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      // Or using socket_io_client:
      // _socket = io(_wsUrl, <String, dynamic>{
      //   'transports': ['websocket'],
      //   'autoConnect': false,
      // });
      
      // Mock connection
      await Future.delayed(Duration(milliseconds: 500));
      
      _state = WebSocketState.connected;
      _reconnectAttempts = 0;
      _notifyConnectionState();
      
      // Start ping-pong heartbeat
      _startPingTimer();
      
      // Emit connected message
      _emitMessage(WebSocketMessage(
        type: WebSocketMessageType.connected,
        data: {'userId': userId},
        userId: userId,
      ));
      
      // In real implementation, listen to socket events
      // _socket.on('message', _handleMessage);
      // _socket.on('disconnect', _handleDisconnect);
      // _socket.on('error', _handleError);
      
    } catch (e) {
      _state = WebSocketState.error;
      _notifyConnectionState(error: 'Failed to connect: $e');
      _scheduleReconnect();
    }
  }
  
  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    
    // TODO: Close actual WebSocket connection
    // _socket?.disconnect();
    // _socket?.dispose();
    
    _state = WebSocketState.disconnected;
    _notifyConnectionState();
  }
  
  /// Send a WebSocket message
  Future<void> sendMessage(WebSocketMessage message) async {
    if (_state != WebSocketState.connected) {
      throw Exception('WebSocket not connected');
    }
    
    try {
      // TODO: Send actual WebSocket message
      // _socket.emit('message', message.toJson());
      
      // Mock implementation - simulate echo
      await Future.delayed(Duration(milliseconds: 50));
      _emitMessage(message);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
  
  /// Send location update
  Future<void> sendLocationUpdate(LiveLocation location) async {
    final message = WebSocketMessage.locationUpdate(
      userId: location.userId,
      latitude: location.latitude,
      longitude: location.longitude,
      speed: location.speed,
      heading: location.heading,
    );
    
    await sendMessage(message);
  }
  
  /// Send friend presence update
  Future<void> sendPresenceUpdate(bool isOnline) async {
    if (_userId == null) return;
    
    final message = WebSocketMessage.friendPresence(
      userId: _userId!,
      isOnline: isOnline,
    );
    
    await sendMessage(message);
  }
  
  /// Send chat message
  Future<void> sendChatMessage({
    required String roomId,
    required String message,
  }) async {
    if (_userId == null) return;
    
    final wsMessage = WebSocketMessage.chatMessage(
      roomId: roomId,
      senderId: _userId!,
      message: message,
    );
    
    await sendMessage(wsMessage);
  }
  
  /// Join room (subscribe to room events)
  Future<void> joinRoom(String roomId) async {
    if (_userId == null) return;
    
    final message = WebSocketMessage(
      type: WebSocketMessageType.roomJoined,
      userId: _userId,
      data: {'roomId': roomId},
    );
    
    await sendMessage(message);
  }
  
  /// Leave room (unsubscribe from room events)
  Future<void> leaveRoom(String roomId) async {
    if (_userId == null) return;
    
    final message = WebSocketMessage(
      type: WebSocketMessageType.roomLeft,
      userId: _userId,
      data: {'roomId': roomId},
    );
    
    await sendMessage(message);
  }
  
  /// Handle incoming message (would be called by WebSocket listener)
  void _handleMessage(Map<String, dynamic> data) {
    try {
      final message = WebSocketMessage.fromJson(data);
      _emitMessage(message);
    } catch (e) {
      print('Failed to parse WebSocket message: $e');
    }
  }
  
  /// Handle disconnection
  void _handleDisconnect() {
    _state = WebSocketState.disconnected;
    _notifyConnectionState();
    _scheduleReconnect();
  }
  
  /// Handle error
  void _handleError(dynamic error) {
    _state = WebSocketState.error;
    _notifyConnectionState(error: error.toString());
    _scheduleReconnect();
  }
  
  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnect attempts reached');
      return;
    }
    
    _reconnectTimer?.cancel();
    _state = WebSocketState.reconnecting;
    _notifyConnectionState();
    
    final delay = _reconnectDelay * (_reconnectAttempts + 1);
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      if (_userId != null) {
        connect(_userId!);
      }
    });
  }
  
  /// Start ping timer for heartbeat
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_state == WebSocketState.connected) {
        _sendPing();
      }
    });
  }
  
  /// Send ping message
  void _sendPing() {
    final message = WebSocketMessage(
      type: WebSocketMessageType.ping,
      data: {},
    );
    sendMessage(message).catchError((e) {
      print('Failed to send ping: $e');
    });
  }
  
  /// Emit message to stream
  void _emitMessage(WebSocketMessage message) {
    _messageController.add(message);
  }
  
  /// Notify connection state change
  void _notifyConnectionState({String? error}) {
    final event = WebSocketConnectionEvent(
      state: _state,
      errorMessage: error,
    );
    _connectionController.add(event);
  }
  
  /// Get current connection state
  WebSocketState get state => _state;
  
  /// Check if connected
  bool get isConnected => _state == WebSocketState.connected;
  
  /// Dispose streams and timers
  void dispose() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
