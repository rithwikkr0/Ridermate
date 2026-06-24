import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/ride_room.dart';

/// Service for managing ride rooms (group rides)
class RideRoomService {
  static const String _baseUrl = 'https://api.ridermate.com';
  
  // Mock data for development
  final List<RideRoom> _rooms = [];
  final Map<String, List<ChatMessage>> _roomMessages = {};
  
  // Stream controllers
  final _roomsController = StreamController<List<RideRoom>>.broadcast();
  final _activeRoomController = StreamController<RideRoom?>.broadcast();
  final _messagesController = StreamController<List<ChatMessage>>.broadcast();
  
  Stream<List<RideRoom>> get roomsStream => _roomsController.stream;
  Stream<RideRoom?> get activeRoomStream => _activeRoomController.stream;
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  
  RideRoom? _activeRoom;
  
  /// Create a new ride room
  Future<RideRoom> createRoom({
    required String hostId,
    required String hostName,
    required String name,
    required bool isPublic,
    int maxCapacity = 10,
  }) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/api/ride-rooms/create'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'hostId': hostId,
      //     'name': name,
      //     'isPublic': isPublic,
      //     'maxCapacity': maxCapacity,
      //   }),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 400));
      
      final room = RideRoom(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        hostId: hostId,
        hostName: hostName,
        participants: [
          RoomParticipant(
            userId: hostId,
            name: hostName,
            username: hostName.toLowerCase().replaceAll(' ', '_'),
            joinedAt: DateTime.now(),
            isHost: true,
            isReady: false,
          ),
        ],
        isPublic: isPublic,
        inviteCode: isPublic ? null : _generateInviteCode(),
        maxCapacity: maxCapacity,
        createdAt: DateTime.now(),
        status: RoomStatus.waiting,
      );
      
      _rooms.add(room);
      _roomsController.add(List.from(_rooms));
      
      return room;
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }
  
  /// Get room details
  Future<RideRoom> getRoom(String roomId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/ride-rooms/$roomId'),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 200));
      
      final room = _rooms.firstWhere(
        (r) => r.id == roomId,
        orElse: () => throw Exception('Room not found'),
      );
      
      return room;
    } catch (e) {
      throw Exception('Failed to get room: $e');
    }
  }
  
  /// Join a ride room
  Future<RideRoom> joinRoom({
    required String roomId,
    required String userId,
    required String userName,
    required String username,
    String? inviteCode,
  }) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/api/ride-rooms/$roomId/join'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'userId': userId,
      //     'inviteCode': inviteCode,
      //   }),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 300));
      
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex == -1) {
        throw Exception('Room not found');
      }
      
      final room = _rooms[roomIndex];
      
      // Validate room capacity
      if (room.isFull) {
        throw Exception('Room is full');
      }
      
      // Validate invite code for private rooms
      if (!room.isPublic && room.inviteCode != inviteCode) {
        throw Exception('Invalid invite code');
      }
      
      // Check if user already in room
      if (room.participants.any((p) => p.userId == userId)) {
        throw Exception('Already in room');
      }
      
      // Add participant
      final participant = RoomParticipant(
        userId: userId,
        name: userName,
        username: username,
        joinedAt: DateTime.now(),
        isHost: false,
        isReady: false,
      );
      
      final updatedParticipants = [...room.participants, participant];
      final updatedRoom = RideRoom(
        id: room.id,
        name: room.name,
        hostId: room.hostId,
        hostName: room.hostName,
        participants: updatedParticipants,
        isPublic: room.isPublic,
        inviteCode: room.inviteCode,
        maxCapacity: room.maxCapacity,
        createdAt: room.createdAt,
        startedAt: room.startedAt,
        endedAt: room.endedAt,
        status: room.status,
      );
      
      _rooms[roomIndex] = updatedRoom;
      _roomsController.add(List.from(_rooms));
      
      if (_activeRoom?.id == roomId) {
        _activeRoom = updatedRoom;
        _activeRoomController.add(_activeRoom);
      }
      
      return updatedRoom;
    } catch (e) {
      throw Exception('Failed to join room: $e');
    }
  }
  
  /// Leave a ride room
  Future<void> leaveRoom(String roomId, String userId) async {
    try {
      // TODO: Replace with actual API call
      // await http.post(
      //   Uri.parse('$_baseUrl/api/ride-rooms/$roomId/leave'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'userId': userId}),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 300));
      
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex == -1) return;
      
      final room = _rooms[roomIndex];
      final updatedParticipants = room.participants
          .where((p) => p.userId != userId)
          .toList();
      
      // If host left, remove room or assign new host
      if (room.hostId == userId) {
        if (updatedParticipants.isEmpty) {
          _rooms.removeAt(roomIndex);
        } else {
          // Assign new host
          updatedParticipants[0] = updatedParticipants[0].copyWith(isHost: true);
          final updatedRoom = RideRoom(
            id: room.id,
            name: room.name,
            hostId: updatedParticipants[0].userId,
            hostName: updatedParticipants[0].name,
            participants: updatedParticipants,
            isPublic: room.isPublic,
            inviteCode: room.inviteCode,
            maxCapacity: room.maxCapacity,
            createdAt: room.createdAt,
            startedAt: room.startedAt,
            endedAt: room.endedAt,
            status: room.status,
          );
          _rooms[roomIndex] = updatedRoom;
        }
      } else {
        final updatedRoom = RideRoom(
          id: room.id,
          name: room.name,
          hostId: room.hostId,
          hostName: room.hostName,
          participants: updatedParticipants,
          isPublic: room.isPublic,
          inviteCode: room.inviteCode,
          maxCapacity: room.maxCapacity,
          createdAt: room.createdAt,
          startedAt: room.startedAt,
          endedAt: room.endedAt,
          status: room.status,
        );
        _rooms[roomIndex] = updatedRoom;
      }
      
      _roomsController.add(List.from(_rooms));
      
      if (_activeRoom?.id == roomId) {
        _activeRoom = null;
        _activeRoomController.add(null);
      }
    } catch (e) {
      throw Exception('Failed to leave room: $e');
    }
  }
  
  /// Invite friend to room
  Future<void> inviteFriend({
    required String roomId,
    required String friendId,
  }) async {
    try {
      // TODO: Replace with actual API call
      // await http.post(
      //   Uri.parse('$_baseUrl/api/ride-rooms/$roomId/invite'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'friendId': friendId}),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 200));
      
      // In real implementation, this would send a notification to the friend
    } catch (e) {
      throw Exception('Failed to invite friend: $e');
    }
  }
  
  /// Get participants in a room
  Future<List<RoomParticipant>> getParticipants(String roomId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/ride-rooms/$roomId/participants'),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 200));
      
      final room = _rooms.firstWhere(
        (r) => r.id == roomId,
        orElse: () => throw Exception('Room not found'),
      );
      
      return room.participants;
    } catch (e) {
      throw Exception('Failed to get participants: $e');
    }
  }
  
  /// Start the ride (host only)
  Future<void> startRide(String roomId) async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex == -1) return;
      
      final room = _rooms[roomIndex];
      final updatedRoom = RideRoom(
        id: room.id,
        name: room.name,
        hostId: room.hostId,
        hostName: room.hostName,
        participants: room.participants,
        isPublic: room.isPublic,
        inviteCode: room.inviteCode,
        maxCapacity: room.maxCapacity,
        createdAt: room.createdAt,
        startedAt: DateTime.now(),
        endedAt: room.endedAt,
        status: RoomStatus.active,
      );
      
      _rooms[roomIndex] = updatedRoom;
      _roomsController.add(List.from(_rooms));
      
      if (_activeRoom?.id == roomId) {
        _activeRoom = updatedRoom;
        _activeRoomController.add(_activeRoom);
      }
    } catch (e) {
      throw Exception('Failed to start ride: $e');
    }
  }
  
  /// Send chat message
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      await Future.delayed(Duration(milliseconds: 100));
      
      final chatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: roomId,
        senderId: senderId,
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      
      if (!_roomMessages.containsKey(roomId)) {
        _roomMessages[roomId] = [];
      }
      
      _roomMessages[roomId]!.add(chatMessage);
      _messagesController.add(List.from(_roomMessages[roomId]!));
      
      return chatMessage;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
  
  /// Get chat messages for a room
  List<ChatMessage> getMessages(String roomId) {
    return _roomMessages[roomId] ?? [];
  }
  
  /// Set active room
  void setActiveRoom(RideRoom? room) {
    _activeRoom = room;
    _activeRoomController.add(room);
  }
  
  /// Generate a random invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
  
  /// Dispose streams
  void dispose() {
    _roomsController.close();
    _activeRoomController.close();
    _messagesController.close();
  }
}
