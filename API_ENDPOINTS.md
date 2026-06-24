# RiderMate Backend API Endpoints

This document specifies the backend API endpoints required to support the RiderMate social features.

## Base URL
```
https://api.ridermate.com
```

## Authentication
All authenticated endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

---

## Friend System Endpoints

### Search Users
Search for users by username or name.

**Endpoint:** `GET /api/users/search`

**Query Parameters:**
- `query` (string, required) - Search query

**Response:**
```json
[
  {
    "id": "user123",
    "name": "Alex Johnson",
    "username": "alex_rides",
    "isFriend": false,
    "hasPendingRequest": false
  }
]
```

---

### Send Friend Request
Send a friend request to another user.

**Endpoint:** `POST /api/friends/request`

**Request Body:**
```json
{
  "senderId": "user123",
  "receiverId": "user456",
  "senderName": "John Doe",
  "senderUsername": "johndoe"
}
```

**Response:**
```json
{
  "id": "req789",
  "senderId": "user123",
  "senderName": "John Doe",
  "senderUsername": "johndoe",
  "receiverId": "user456",
  "status": "pending",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

### Accept Friend Request
Accept a pending friend request.

**Endpoint:** `POST /api/friends/accept`

**Request Body:**
```json
{
  "requestId": "req789"
}
```

**Response:**
```json
{
  "id": "friend123",
  "userId": "user456",
  "friendId": "user123",
  "friendName": "John Doe",
  "friendUsername": "johndoe",
  "status": "accepted",
  "createdAt": "2024-01-15T10:35:00Z",
  "isOnline": false
}
```

---

### Reject Friend Request
Reject a pending friend request.

**Endpoint:** `POST /api/friends/reject`

**Request Body:**
```json
{
  "requestId": "req789"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Friend request rejected"
}
```

---

### Get Friends List
Get all friends for a user.

**Endpoint:** `GET /api/friends/:userId`

**Response:**
```json
[
  {
    "id": "friend123",
    "userId": "user456",
    "friendId": "user123",
    "friendName": "John Doe",
    "friendUsername": "johndoe",
    "status": "accepted",
    "createdAt": "2024-01-15T10:35:00Z",
    "isOnline": true,
    "lastSeen": "2024-01-15T12:00:00Z"
  }
]
```

---

### Remove Friend
Remove a friend.

**Endpoint:** `DELETE /api/friends/:friendId`

**Response:**
```json
{
  "success": true,
  "message": "Friend removed"
}
```

---

## Ride Room Endpoints

### Create Ride Room
Create a new ride room.

**Endpoint:** `POST /api/ride-rooms/create`

**Request Body:**
```json
{
  "hostId": "user123",
  "hostName": "John Doe",
  "name": "Morning City Ride",
  "isPublic": true,
  "maxCapacity": 10
}
```

**Response:**
```json
{
  "id": "room456",
  "name": "Morning City Ride",
  "hostId": "user123",
  "hostName": "John Doe",
  "participants": [
    {
      "userId": "user123",
      "name": "John Doe",
      "username": "johndoe",
      "joinedAt": "2024-01-15T10:00:00Z",
      "isHost": true,
      "isReady": false
    }
  ],
  "isPublic": true,
  "inviteCode": null,
  "maxCapacity": 10,
  "createdAt": "2024-01-15T10:00:00Z",
  "status": "waiting"
}
```

---

### Get Ride Room
Get details of a specific ride room.

**Endpoint:** `GET /api/ride-rooms/:roomId`

**Response:**
```json
{
  "id": "room456",
  "name": "Morning City Ride",
  "hostId": "user123",
  "hostName": "John Doe",
  "participants": [...],
  "isPublic": true,
  "inviteCode": "ABC123",
  "maxCapacity": 10,
  "createdAt": "2024-01-15T10:00:00Z",
  "startedAt": null,
  "endedAt": null,
  "status": "waiting"
}
```

---

### Join Ride Room
Join an existing ride room.

**Endpoint:** `POST /api/ride-rooms/:roomId/join`

**Request Body:**
```json
{
  "userId": "user789",
  "userName": "Jane Smith",
  "username": "janesmith",
  "inviteCode": "ABC123"
}
```

**Response:**
```json
{
  "id": "room456",
  "name": "Morning City Ride",
  "participants": [
    {
      "userId": "user123",
      "name": "John Doe",
      "username": "johndoe",
      "joinedAt": "2024-01-15T10:00:00Z",
      "isHost": true,
      "isReady": false
    },
    {
      "userId": "user789",
      "name": "Jane Smith",
      "username": "janesmith",
      "joinedAt": "2024-01-15T10:05:00Z",
      "isHost": false,
      "isReady": false
    }
  ],
  ...
}
```

---

### Leave Ride Room
Leave a ride room.

**Endpoint:** `POST /api/ride-rooms/:roomId/leave`

**Request Body:**
```json
{
  "userId": "user789"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Left room successfully"
}
```

---

### Invite Friend to Room
Invite a friend to join a ride room.

**Endpoint:** `POST /api/ride-rooms/:roomId/invite`

**Request Body:**
```json
{
  "friendId": "user999"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invitation sent"
}
```

---

### Get Room Participants
Get all participants in a room.

**Endpoint:** `GET /api/ride-rooms/:roomId/participants`

**Response:**
```json
[
  {
    "userId": "user123",
    "name": "John Doe",
    "username": "johndoe",
    "joinedAt": "2024-01-15T10:00:00Z",
    "isHost": true,
    "isReady": false
  }
]
```

---

## Location Sharing Endpoints

### Share Location
Share current location (can be REST or WebSocket).

**Endpoint:** `POST /api/location/share`

**Request Body:**
```json
{
  "userId": "user123",
  "userName": "John Doe",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "speed": 25.5,
  "heading": 180.0,
  "accuracy": 5.0,
  "timestamp": "2024-01-15T10:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Location updated"
}
```

---

### Get Friend Locations
Get current locations of all friends.

**Endpoint:** `GET /api/location/friends`

**Response:**
```json
[
  {
    "userId": "user456",
    "userName": "Jane Smith",
    "latitude": 12.9720,
    "longitude": 77.5950,
    "speed": 20.0,
    "heading": 90.0,
    "accuracy": 8.0,
    "timestamp": "2024-01-15T10:00:00Z",
    "isSharing": true
  }
]
```

---

### Stop Location Sharing
Stop sharing location.

**Endpoint:** `POST /api/location/stop-sharing`

**Response:**
```json
{
  "success": true,
  "message": "Location sharing stopped"
}
```

---

### Update Location Settings
Update location sharing preferences.

**Endpoint:** `POST /api/location/settings`

**Request Body:**
```json
{
  "enabled": true,
  "privacy": "friendsOnly",
  "allowedFriends": [],
  "shareSpeed": true,
  "shareHeading": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Settings updated"
}
```

---

## WebSocket Events

Connect to WebSocket at: `wss://api.ridermate.com/ws`

### Client to Server Events

#### Location Update
```json
{
  "type": "locationUpdate",
  "userId": "user123",
  "data": {
    "latitude": 12.9716,
    "longitude": 77.5946,
    "speed": 25.5,
    "heading": 180.0
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Friend Presence
```json
{
  "type": "friendPresence",
  "userId": "user123",
  "data": {
    "isOnline": true
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Chat Message
```json
{
  "type": "chatMessage",
  "userId": "user123",
  "data": {
    "roomId": "room456",
    "message": "Hello everyone!"
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Join Room
```json
{
  "type": "roomJoined",
  "userId": "user123",
  "data": {
    "roomId": "room456"
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

### Server to Client Events

#### Connected
```json
{
  "type": "connected",
  "data": {
    "userId": "user123"
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Location Update
```json
{
  "type": "locationUpdate",
  "userId": "user456",
  "data": {
    "latitude": 12.9720,
    "longitude": 77.5950,
    "speed": 20.0,
    "heading": 90.0
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Friend Request
```json
{
  "type": "friendRequest",
  "userId": "user789",
  "data": {
    "requestId": "req123",
    "senderName": "Alex Johnson"
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Friend Accepted
```json
{
  "type": "friendAccepted",
  "userId": "user789",
  "data": {
    "friendId": "user123",
    "friendName": "John Doe"
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Room Update
```json
{
  "type": "roomUpdate",
  "data": {
    "roomId": "room456",
    "status": "active",
    "participants": [...]
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Participant Joined
```json
{
  "type": "participantJoined",
  "data": {
    "roomId": "room456",
    "participant": {
      "userId": "user789",
      "name": "Jane Smith",
      "username": "janesmith"
    }
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

#### Error
```json
{
  "type": "error",
  "data": {
    "message": "Authentication failed",
    "code": "AUTH_ERROR"
  },
  "timestamp": "2024-01-15T10:00:00Z"
}
```

---

## Error Responses

All endpoints return errors in the following format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {}
  }
}
```

### Common Error Codes
- `AUTH_ERROR` - Authentication failed
- `VALIDATION_ERROR` - Invalid request data
- `NOT_FOUND` - Resource not found
- `FORBIDDEN` - Insufficient permissions
- `RATE_LIMIT` - Too many requests
- `SERVER_ERROR` - Internal server error

---

## Rate Limiting

- Friend searches: 30 requests per minute
- Location updates: 120 requests per minute (1 every 2 seconds)
- Friend requests: 10 requests per hour
- Room creation: 5 requests per hour

---

## Database Schema

### Collections

#### friends
```javascript
{
  id: string,
  userId: string,
  friendId: string,
  status: 'pending' | 'accepted' | 'blocked',
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### friend_requests
```javascript
{
  id: string,
  senderId: string,
  receiverId: string,
  status: 'pending' | 'accepted' | 'rejected' | 'cancelled',
  createdAt: timestamp,
  respondedAt: timestamp?
}
```

#### ride_rooms
```javascript
{
  id: string,
  name: string,
  hostId: string,
  participants: array,
  isPublic: boolean,
  inviteCode: string?,
  maxCapacity: number,
  status: 'waiting' | 'active' | 'finished' | 'cancelled',
  createdAt: timestamp,
  startedAt: timestamp?,
  endedAt: timestamp?
}
```

#### live_locations
```javascript
{
  userId: string,
  latitude: number,
  longitude: number,
  speed: number?,
  heading: number?,
  accuracy: number?,
  timestamp: timestamp,
  expiresAt: timestamp  // Auto-delete after 5 minutes
}
```

---

## Security Considerations

1. **Authentication**: All endpoints require valid JWT tokens
2. **Rate Limiting**: Implemented on all endpoints
3. **Data Validation**: Strict validation on all inputs
4. **Privacy**: Location data only shared with accepted friends
5. **Encryption**: All data transmitted over HTTPS/WSS
6. **Data Retention**: Location data auto-expires after ride

---

## Testing

Use the provided Postman collection for testing all endpoints:
- `RiderMate_API.postman_collection.json` (to be created)

Example cURL request:
```bash
curl -X POST https://api.ridermate.com/api/friends/request \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "senderId": "user123",
    "receiverId": "user456"
  }'
```

---

For implementation details and client-side integration, see `SOCIAL_FEATURES.md`.
