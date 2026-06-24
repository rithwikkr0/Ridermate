# RiderMate Social Features Documentation

This document provides comprehensive documentation for the social features implemented in the RiderMate app.

## Overview

The social features include:
1. **Friend System** - Search, add, and manage friends
2. **Ride Rooms** - Create and join group rides
3. **Real-Time Location Sharing** - Share live location with friends
4. **WebSocket Integration** - Real-time updates for all features

## Architecture

### Models (`lib/models/`)

#### Friend Models
- **Friend** - Represents a friendship relationship
- **FriendRequest** - Represents a pending friend request
- **UserSearchResult** - User data from search results
- **FriendStatus** - Enum for friend relationship status
- **FriendRequestStatus** - Enum for request status

#### Ride Room Models
- **RideRoom** - Group ride room with participants
- **RoomParticipant** - Individual participant in a room
- **ChatMessage** - Chat message in a room
- **RoomStatus** - Enum for room state (waiting, active, finished)

#### Location Models
- **LiveLocation** - Real-time location data
- **LocationUpdate** - Location update event
- **LocationSharingSettings** - Privacy and sharing settings
- **LocationPrivacy** - Enum for privacy levels

#### WebSocket Models
- **WebSocketMessage** - Generic message structure
- **WebSocketMessageType** - Enum for message types
- **WebSocketState** - Connection state enum
- **WebSocketConnectionEvent** - Connection status event

### Services (`lib/services/`)

#### FriendService
Manages friend relationships and requests.

**Key Methods:**
```dart
// Search for users
Future<List<UserSearchResult>> searchUsers(String query)

// Send friend request
Future<FriendRequest> sendFriendRequest({
  required String senderId,
  required String receiverId,
  required String senderName,
  required String senderUsername,
})

// Accept friend request
Future<Friend> acceptFriendRequest(String requestId, String userId)

// Reject friend request
Future<void> rejectFriendRequest(String requestId)

// Remove friend
Future<void> removeFriend(String friendId)

// Get friends list
Future<List<Friend>> getFriends(String userId)

// Get pending requests
Future<List<FriendRequest>> getPendingRequests(String userId)
```

**Streams:**
- `friendsStream` - Real-time friend list updates
- `requestsStream` - Real-time friend request updates

#### RideRoomService
Manages ride rooms and group rides.

**Key Methods:**
```dart
// Create new room
Future<RideRoom> createRoom({
  required String hostId,
  required String hostName,
  required String name,
  required bool isPublic,
  int maxCapacity = 10,
})

// Get room details
Future<RideRoom> getRoom(String roomId)

// Join room
Future<RideRoom> joinRoom({
  required String roomId,
  required String userId,
  required String userName,
  required String username,
  String? inviteCode,
})

// Leave room
Future<void> leaveRoom(String roomId, String userId)

// Invite friend
Future<void> inviteFriend({
  required String roomId,
  required String friendId,
})

// Send chat message
Future<ChatMessage> sendMessage({
  required String roomId,
  required String senderId,
  required String senderName,
  required String message,
})
```

**Streams:**
- `roomsStream` - Real-time room list updates
- `activeRoomStream` - Current active room updates
- `messagesStream` - Chat message updates

#### LocationService
Handles location tracking and sharing.

**Key Methods:**
```dart
// Start sharing location
Future<void> startSharingLocation({
  required String userId,
  required String userName,
})

// Stop sharing location
Future<void> stopSharingLocation()

// Get friend locations
Future<Map<String, LiveLocation>> getFriendLocations()

// Update settings
Future<void> updateSettings(LocationSharingSettings settings)
```

**Streams:**
- `locationsStream` - Real-time friend location updates
- `settingsStream` - Location sharing settings updates
- `myLocationStream` - Own location updates

**Features:**
- Automatic location updates every 2-3 seconds
- Privacy controls (friends only, selected friends, public, none)
- Stale location detection (removes after 30 seconds of inactivity)
- Distance calculation between locations

#### WebSocketHandler
Manages real-time WebSocket connections.

**Key Methods:**
```dart
// Connect to server
Future<void> connect(String userId)

// Disconnect
Future<void> disconnect()

// Send message
Future<void> sendMessage(WebSocketMessage message)

// Send location update
Future<void> sendLocationUpdate(LiveLocation location)

// Send presence update
Future<void> sendPresenceUpdate(bool isOnline)

// Join/leave room events
Future<void> joinRoom(String roomId)
Future<void> leaveRoom(String roomId)
```

**Streams:**
- `messageStream` - Incoming WebSocket messages
- `connectionStream` - Connection state changes

**Features:**
- Automatic reconnection with exponential backoff
- Ping/pong heartbeat (every 30 seconds)
- Connection state management
- Error handling and graceful degradation

### Widgets (`lib/widgets/`)

#### FriendSearchWidget
Search for users and send friend requests.

**Props:**
- `friendService` - FriendService instance
- `currentUserId` - Current user ID

**Features:**
- Real-time search as you type
- Shows friend status (already friends, pending request)
- Send friend requests with one tap

#### FriendsListWidget
Display list of friends.

**Props:**
- `friendService` - FriendService instance
- `currentUserId` - Current user ID

**Features:**
- Online status indicators
- Pull-to-refresh
- Remove friend option
- Empty state

#### FriendRequestsWidget
Manage incoming friend requests.

**Props:**
- `friendService` - FriendService instance
- `currentUserId` - Current user ID

**Features:**
- Accept/reject requests
- Time since request received
- Empty state

#### FriendRequestBadge
Notification badge for friend requests.

**Props:**
- `friendService` - FriendService instance
- `currentUserId` - Current user ID
- `onTap` - Callback when tapped

**Features:**
- Shows count of pending requests
- Real-time updates

#### CreateRideRoomWidget
Create a new ride room.

**Props:**
- `roomService` - RideRoomService instance
- `currentUserId` - Current user ID
- `currentUserName` - Current user name

**Features:**
- Set room name
- Choose public/private
- Set max capacity (2-20)
- Generates invite code for private rooms

#### RideRoomWidget
View and interact with a ride room.

**Props:**
- `room` - RideRoom instance
- `roomService` - RideRoomService instance
- `currentUserId` - Current user ID
- `onLeave` - Callback when leaving room

**Features:**
- View participants
- Group chat
- Start ride (host only)
- Copy invite code
- Leave room

#### LocationSharingToggle
Control location sharing.

**Props:**
- `locationService` - LocationService instance
- `currentUserId` - Current user ID
- `currentUserName` - Current user name

**Features:**
- Toggle location sharing on/off
- Access privacy settings
- Visual indicator when sharing

#### LiveLocationMapWidget
Display friend locations on a map.

**Props:**
- `locationService` - LocationService instance
- `currentUserId` - Current user ID

**Features:**
- Shows all active friend locations
- Displays speed and coordinates
- Stale location indicators
- Empty state when no locations active

### Screens (`lib/screens/`)

#### FriendsScreen
Main friends management screen with tabs.

**Tabs:**
1. My Friends - List of friends
2. Search - Search for new friends
3. Requests - Pending friend requests (with badge)

#### RideRoomsScreen
Browse and manage ride rooms.

**Features:**
- List of available rooms
- Create new room (FAB)
- Join by invite code
- Shows active room banner if in a room

#### SocialHubScreen
Central hub for all social features.

**Sections:**
- Location sharing toggle
- Live location map
- Quick action buttons (Friends, Ride Rooms)
- Friends preview

## Implementation Guide

### Basic Setup

1. **Initialize Services** (in main.dart or app state):

```dart
final friendService = FriendService();
final roomService = RideRoomService();
final locationService = LocationService();
final webSocketHandler = WebSocketHandler();

// Connect WebSocket
await webSocketHandler.connect(currentUserId);
```

2. **Use in Widgets**:

```dart
SocialHubScreen(
  friendService: friendService,
  roomService: roomService,
  locationService: locationService,
  currentUserId: currentUserId,
  currentUserName: currentUserName,
)
```

### Backend Integration

The current implementation uses mock data. To integrate with a real backend:

1. **Update Service Methods**:
   - Uncomment the API call code in each service
   - Replace mock implementations with actual HTTP requests
   - Handle authentication tokens

2. **Add Dependencies** (pubspec.yaml):
```yaml
dependencies:
  http: ^1.1.0
  socket_io_client: ^2.0.3+1
  geolocator: ^10.1.0
  google_maps_flutter: ^2.5.0
```

3. **Update API URLs**:
   - Set `_baseUrl` in each service to your backend URL
   - Configure WebSocket URL in `WebSocketHandler`

4. **Add Authentication**:
   - Implement JWT token handling
   - Add auth headers to API requests
   - Handle token refresh

### WebSocket Integration

Replace mock WebSocket in `WebSocketHandler`:

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketHandler {
  IO.Socket? _socket;
  
  Future<void> connect(String userId) async {
    _socket = IO.io('wss://api.ridermate.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'userId': userId},
    });
    
    _socket!.on('connect', (_) {
      _state = WebSocketState.connected;
      _notifyConnectionState();
    });
    
    _socket!.on('message', (data) {
      _handleMessage(data);
    });
    
    _socket!.on('disconnect', (_) {
      _handleDisconnect();
    });
    
    _socket!.connect();
  }
}
```

### Location Services

Integrate real GPS using geolocator:

```dart
import 'package:geolocator/geolocator.dart';

Future<void> _updateMyLocation(String userId, String userName) async {
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  
  _myLocation = LiveLocation(
    userId: userId,
    userName: userName,
    latitude: position.latitude,
    longitude: position.longitude,
    speed: position.speed,
    heading: position.heading,
    accuracy: position.accuracy,
    timestamp: DateTime.now(),
    isSharing: true,
  );
  
  await _sendLocationUpdate(_myLocation!);
}
```

### Map Integration

Replace map placeholder with Google Maps:

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(myLocation.latitude, myLocation.longitude),
    zoom: 14,
  ),
  markers: _buildMarkers(),
  onMapCreated: (controller) {
    _mapController = controller;
  },
)
```

## Security Considerations

1. **Location Privacy**:
   - Only share location with accepted friends
   - Respect user privacy settings
   - Auto-expire location data after ride

2. **WebSocket Security**:
   - Use WSS (secure WebSocket)
   - Implement authentication
   - Validate all incoming messages

3. **Data Validation**:
   - Validate all user input
   - Sanitize chat messages
   - Check permissions before sharing data

4. **Error Handling**:
   - Graceful degradation if WebSocket fails
   - Fallback to polling if needed
   - User-friendly error messages

## Testing

### Unit Tests

Test individual services:

```dart
test('FriendService sends friend request', () async {
  final service = FriendService();
  final request = await service.sendFriendRequest(
    senderId: 'user1',
    receiverId: 'user2',
    senderName: 'Test User',
    senderUsername: 'testuser',
  );
  
  expect(request.senderId, 'user1');
  expect(request.receiverId, 'user2');
  expect(request.status, FriendRequestStatus.pending);
});
```

### Widget Tests

Test widget behavior:

```dart
testWidgets('FriendSearchWidget displays search results', (tester) async {
  final service = FriendService();
  
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: FriendSearchWidget(
        friendService: service,
        currentUserId: 'test',
      ),
    ),
  ));
  
  await tester.enterText(find.byType(TextField), 'alex');
  await tester.pump();
  
  expect(find.text('Alex Johnson'), findsOneWidget);
});
```

## Performance Optimization

1. **Location Updates**:
   - Adjust update frequency based on speed
   - Batch location updates
   - Use location accuracy levels appropriately

2. **Stream Management**:
   - Always dispose streams in widgets
   - Unsubscribe when not needed
   - Use broadcast streams for multiple listeners

3. **State Management**:
   - Consider using Provider or Riverpod for global state
   - Minimize widget rebuilds
   - Use const widgets where possible

## Troubleshooting

### Common Issues

1. **WebSocket won't connect**:
   - Check network connectivity
   - Verify WebSocket URL
   - Check authentication

2. **Location not updating**:
   - Verify location permissions
   - Check GPS availability
   - Ensure location service is running

3. **Friends not appearing**:
   - Check friend status
   - Verify API responses
   - Check stream subscriptions

## Future Enhancements

1. **Voice/Video Calls** - Add call functionality between friends
2. **Route Sharing** - Share planned routes with friends
3. **Leaderboards** - Compete with friends on distance/speed
4. **Ride History** - View past group rides
5. **Notifications** - Push notifications for requests and invites
6. **Media Sharing** - Share photos from rides in chat
7. **Custom Avatars** - Profile pictures for users
8. **Friend Suggestions** - AI-powered friend recommendations

## API Reference

See inline documentation in service files for detailed API reference.

## Support

For questions or issues, please refer to the main repository documentation or contact the development team.
