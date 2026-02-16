# API Reference

## Base URL

```
Development: http://localhost:5000/api
Production: https://your-domain.com/api
```

## Authentication

All endpoints (except `/auth/register` and `/auth/login`) require authentication.

### Headers

```
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

## Response Format

### Success Response
```json
{
  "message": "Success message",
  "data": { ... }
}
```

### Error Response
```json
{
  "error": "Error message",
  "details": [ ... ] // optional
}
```

## Endpoints

### Authentication

#### Register User
```http
POST /api/auth/register
```

Handled by Firebase client SDK.

#### Login User
```http
POST /api/auth/login
```

Handled by Firebase client SDK.

#### Verify Token
```http
GET /api/auth/verify
```

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "message": "Token is valid",
  "user": {
    "uid": "user123",
    "email": "user@example.com"
  }
}
```

#### Logout
```http
POST /api/auth/logout
```

**Response:**
```json
{
  "message": "Logged out successfully"
}
```

---

### Users

#### Get Current User Profile
```http
GET /api/users/me
```

**Response:**
```json
{
  "id": "user123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoURL": "https://...",
  "stats": {
    "totalRides": 42,
    "totalDistance": 523.5,
    "points": 1250,
    "streak": 7
  }
}
```

#### Update User Profile
```http
PUT /api/users/me
```

**Request Body:**
```json
{
  "displayName": "Jane Doe",
  "privacySettings": {
    "shareLocation": true,
    "shareRides": true,
    "showInLeaderboard": true
  }
}
```

**Response:**
```json
{
  "message": "Profile updated successfully",
  "data": { ... }
}
```

#### Get User Stats
```http
GET /api/users/me/stats
```

**Response:**
```json
{
  "totalRides": 42,
  "totalDistance": 523.5,
  "totalDuration": 15600,
  "points": 1250,
  "level": 5,
  "streak": 7,
  "badges": ["first-ride", "10-rides", "100km"]
}
```

---

### Rides

#### Start New Ride
```http
POST /api/rides/start
```

**Request Body:**
```json
{
  "startLocation": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "timestamp": "2024-01-15T10:30:00Z",
    "speed": 0,
    "accuracy": 10
  }
}
```

**Response:**
```json
{
  "message": "Ride started",
  "rideId": "ride123",
  "data": {
    "id": "ride123",
    "userId": "user123",
    "startTime": "2024-01-15T10:30:00Z",
    "status": "active"
  }
}
```

#### Update Ride Location
```http
PUT /api/rides/:rideId/location
```

**Request Body:**
```json
{
  "latitude": 40.7138,
  "longitude": -74.0070,
  "timestamp": "2024-01-15T10:31:00Z",
  "speed": 15.5,
  "accuracy": 8
}
```

**Response:**
```json
{
  "message": "Location updated"
}
```

#### End Ride
```http
POST /api/rides/:rideId/end
```

**Response:**
```json
{
  "message": "Ride ended",
  "duration": 3600
}
```

#### Get User Rides
```http
GET /api/rides?limit=20&status=completed
```

**Query Parameters:**
- `limit` (optional): Number of rides to return (default: 20)
- `status` (optional): Filter by status (active, completed, paused)

**Response:**
```json
{
  "rides": [
    {
      "id": "ride123",
      "startTime": "2024-01-15T10:30:00Z",
      "endTime": "2024-01-15T11:30:00Z",
      "distance": 12.5,
      "duration": 3600,
      "averageSpeed": 12.5,
      "maxSpeed": 25.3,
      "safetyScore": 92,
      "status": "completed"
    }
  ]
}
```

#### Get Ride Details
```http
GET /api/rides/:rideId
```

**Response:**
```json
{
  "id": "ride123",
  "userId": "user123",
  "startTime": "2024-01-15T10:30:00Z",
  "endTime": "2024-01-15T11:30:00Z",
  "distance": 12.5,
  "duration": 3600,
  "averageSpeed": 12.5,
  "maxSpeed": 25.3,
  "route": [
    {
      "latitude": 40.7128,
      "longitude": -74.0060,
      "timestamp": "2024-01-15T10:30:00Z",
      "speed": 0,
      "accuracy": 10
    }
  ],
  "overspeeds": [],
  "safetyScore": 92,
  "status": "completed"
}
```

---

### Social

#### Send Friend Request
```http
POST /api/social/friends/request
```

**Request Body:**
```json
{
  "friendId": "user456"
}
```

**Response:**
```json
{
  "message": "Friend request sent",
  "requestId": "friend123"
}
```

#### Accept Friend Request
```http
PUT /api/social/friends/:requestId/accept
```

**Response:**
```json
{
  "message": "Friend request accepted"
}
```

#### Get Friends List
```http
GET /api/social/friends
```

**Response:**
```json
{
  "friends": [
    {
      "id": "friend123",
      "userId": "user123",
      "friendId": "user456",
      "status": "accepted",
      "createdAt": "2024-01-10T12:00:00Z"
    }
  ]
}
```

#### Create Ride Room
```http
POST /api/social/rooms
```

**Request Body:**
```json
{
  "name": "Weekend Ride"
}
```

**Response:**
```json
{
  "message": "Ride room created",
  "roomId": "room123",
  "data": {
    "id": "room123",
    "name": "Weekend Ride",
    "creatorId": "user123",
    "participants": ["user123"],
    "isActive": true
  }
}
```

#### Join Ride Room
```http
POST /api/social/rooms/:roomId/join
```

**Response:**
```json
{
  "message": "Joined ride room"
}
```

#### Get Active Ride Rooms
```http
GET /api/social/rooms
```

**Response:**
```json
{
  "rooms": [
    {
      "id": "room123",
      "name": "Weekend Ride",
      "creatorId": "user123",
      "participants": ["user123", "user456"],
      "isActive": true,
      "createdAt": "2024-01-15T09:00:00Z"
    }
  ]
}
```

---

### AI Coach

#### Chat with AI
```http
POST /api/ai/chat
```

**Request Body:**
```json
{
  "message": "How can I improve my cycling performance?"
}
```

**Response:**
```json
{
  "message": "To improve your cycling performance, focus on...",
  "timestamp": "2024-01-15T12:00:00Z"
}
```

#### Get Chat History
```http
GET /api/ai/chat/history?limit=50
```

**Query Parameters:**
- `limit` (optional): Number of messages (default: 50)

**Response:**
```json
{
  "messages": [
    {
      "id": "msg123",
      "userId": "user123",
      "role": "user",
      "content": "How can I improve?",
      "timestamp": "2024-01-15T12:00:00Z"
    },
    {
      "id": "msg124",
      "userId": "user123",
      "role": "assistant",
      "content": "To improve...",
      "timestamp": "2024-01-15T12:00:05Z"
    }
  ]
}
```

#### Generate Weekly Summary
```http
POST /api/ai/summary/weekly
```

**Response:**
```json
{
  "stats": {
    "totalRides": 7,
    "totalDistance": 85.3,
    "totalDuration": 18000,
    "averageSpeed": 17.06
  },
  "summary": "Great week! You completed 7 rides covering 85.3km...",
  "generatedAt": "2024-01-15T12:00:00Z"
}
```

---

### Gamification

#### Get All Achievements
```http
GET /api/gamification/achievements
```

**Response:**
```json
{
  "achievements": [
    {
      "id": "first-ride",
      "name": "First Ride",
      "description": "Complete your first ride",
      "icon": "🚴",
      "points": 10,
      "requirement": "Complete 1 ride"
    }
  ]
}
```

#### Get User Achievements
```http
GET /api/gamification/achievements/me
```

**Response:**
```json
{
  "achievements": [
    {
      "userId": "user123",
      "achievementId": "first-ride",
      "unlockedAt": "2024-01-10T15:30:00Z"
    }
  ]
}
```

#### Get Leaderboard
```http
GET /api/gamification/leaderboard?type=points&limit=10
```

**Query Parameters:**
- `type` (optional): points, distance, or rides (default: points)
- `limit` (optional): Number of entries (default: 10)

**Response:**
```json
{
  "leaderboard": [
    {
      "rank": 1,
      "id": "user123",
      "displayName": "John Doe",
      "photoURL": "https://...",
      "stats": {
        "points": 1250
      }
    }
  ]
}
```

#### Add Points
```http
POST /api/gamification/points/add
```

**Request Body:**
```json
{
  "points": 50,
  "reason": "Completed 10km ride"
}
```

**Response:**
```json
{
  "message": "Points added",
  "newTotal": 1300,
  "reason": "Completed 10km ride"
}
```

---

### Analytics

#### Get Ride Analytics
```http
GET /api/analytics/rides?period=30
```

**Query Parameters:**
- `period` (optional): Days to analyze (default: 30)

**Response:**
```json
{
  "analytics": {
    "totalRides": 15,
    "totalDistance": 187.5,
    "totalDuration": 45000,
    "averageSpeed": 15.0,
    "maxSpeed": 32.5,
    "averageSafetyScore": 88.5
  },
  "rides": [ ... ]
}
```

#### Get Performance Trends
```http
GET /api/analytics/trends
```

**Response:**
```json
{
  "trends": [
    {
      "week": "2024-W01",
      "rides": 3,
      "distance": 42.5,
      "duration": 9000
    }
  ]
}
```

#### Get Safety Analytics
```http
GET /api/analytics/safety
```

**Response:**
```json
{
  "safetyAnalytics": {
    "averageSafetyScore": 88.5,
    "totalOverspeeds": 12,
    "safeRides": 42,
    "riskyRides": 3
  }
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid or missing token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

## Rate Limiting

- Window: 15 minutes
- Max Requests: 100 per window
- Response Header: `X-RateLimit-Remaining`

## Versioning

Currently on v1. Future versions will be indicated in the URL:
```
/api/v2/...
```
