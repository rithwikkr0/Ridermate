import 'dart:async';
import 'dart:convert';
import '../models/friend.dart';

/// Service for managing friend relationships
class FriendService {
  // In a real app, this would be your API base URL
  static const String _baseUrl = 'https://api.ridermate.com';
  
  // Mock data for development - in production, this would be removed
  final List<Friend> _friends = [];
  final List<FriendRequest> _friendRequests = [];
  
  // Stream controllers for real-time updates
  final _friendsController = StreamController<List<Friend>>.broadcast();
  final _requestsController = StreamController<List<FriendRequest>>.broadcast();
  
  Stream<List<Friend>> get friendsStream => _friendsController.stream;
  Stream<List<FriendRequest>> get requestsStream => _requestsController.stream;
  
  /// Search users by username or name
  Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/users/search?query=$query'),
      // );
      // 
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((user) => UserSearchResult.fromJson(user)).toList();
      // }
      
      // Mock implementation for development
      await Future.delayed(Duration(milliseconds: 500));
      
      // Simulate search results
      final mockUsers = [
        UserSearchResult(
          id: '1',
          name: 'Alex Johnson',
          username: 'alex_rides',
          isFriend: false,
          hasPendingRequest: false,
        ),
        UserSearchResult(
          id: '2',
          name: 'Jordan Smith',
          username: 'jordan_cycles',
          isFriend: true,
          hasPendingRequest: false,
        ),
        UserSearchResult(
          id: '3',
          name: 'Sam Wilson',
          username: 'sam_bike',
          isFriend: false,
          hasPendingRequest: true,
        ),
      ];
      
      return mockUsers
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
  
  /// Send a friend request
  Future<FriendRequest> sendFriendRequest({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String senderUsername,
  }) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/api/friends/request'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'senderId': senderId,
      //     'receiverId': receiverId,
      //   }),
      // );
      //
      // if (response.statusCode == 200) {
      //   return FriendRequest.fromJson(json.decode(response.body));
      // }
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 300));
      
      final request = FriendRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        senderName: senderName,
        senderUsername: senderUsername,
        receiverId: receiverId,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );
      
      _friendRequests.add(request);
      _requestsController.add(List.from(_friendRequests));
      
      return request;
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }
  
  /// Accept a friend request
  Future<Friend> acceptFriendRequest(String requestId, String userId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/api/friends/accept'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'requestId': requestId}),
      // );
      //
      // if (response.statusCode == 200) {
      //   return Friend.fromJson(json.decode(response.body));
      // }
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 300));
      
      final requestIndex = _friendRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex == -1) {
        throw Exception('Friend request not found');
      }
      
      final request = _friendRequests[requestIndex];
      
      final friend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        friendId: request.senderId,
        friendName: request.senderName,
        friendUsername: request.senderUsername,
        status: FriendStatus.accepted,
        createdAt: DateTime.now(),
      );
      
      _friends.add(friend);
      _friendRequests.removeAt(requestIndex);
      
      _friendsController.add(List.from(_friends));
      _requestsController.add(List.from(_friendRequests));
      
      return friend;
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }
  
  /// Reject a friend request
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/api/friends/reject'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'requestId': requestId}),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 300));
      
      _friendRequests.removeWhere((r) => r.id == requestId);
      _requestsController.add(List.from(_friendRequests));
    } catch (e) {
      throw Exception('Failed to reject friend request: $e');
    }
  }
  
  /// Remove a friend
  Future<void> removeFriend(String friendId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.delete(
      //   Uri.parse('$_baseUrl/api/friends/$friendId'),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 300));
      
      _friends.removeWhere((f) => f.id == friendId);
      _friendsController.add(List.from(_friends));
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }
  
  /// Get friends list for a user
  Future<List<Friend>> getFriends(String userId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/friends/$userId'),
      // );
      //
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((friend) => Friend.fromJson(friend)).toList();
      // }
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 300));
      return List.from(_friends);
    } catch (e) {
      throw Exception('Failed to get friends: $e');
    }
  }
  
  /// Get pending friend requests
  Future<List<FriendRequest>> getPendingRequests(String userId) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/friends/requests/$userId'),
      // );
      
      // Mock implementation
      await Future.delayed(Duration(milliseconds: 300));
      return _friendRequests
          .where((r) =>
              r.receiverId == userId &&
              r.status == FriendRequestStatus.pending)
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending requests: $e');
    }
  }
  
  /// Update friend online status (called by WebSocket)
  void updateFriendStatus(String friendId, bool isOnline, DateTime? lastSeen) {
    final index = _friends.indexWhere((f) => f.friendId == friendId);
    if (index != -1) {
      _friends[index] = _friends[index].copyWith(
        isOnline: isOnline,
        lastSeen: lastSeen,
      );
      _friendsController.add(List.from(_friends));
    }
  }
  
  /// Dispose streams
  void dispose() {
    _friendsController.close();
    _requestsController.close();
  }
}
