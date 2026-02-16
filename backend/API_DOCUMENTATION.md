# RiderMate Gamification API Documentation

## Base URL
```
http://localhost:3000/api
```

## Endpoints

### Leaderboard Endpoints

#### 1. Get Global Leaderboard
Get the global leaderboard for all users.

**Endpoint:** `GET /leaderboard/global`

**Query Parameters:**
- `period` (optional): `weekly`, `monthly`, or `all_time` (default: `all_time`)
- `limit` (optional): Number of entries to return (default: 100)

**Example Request:**
```bash
curl http://localhost:3000/api/leaderboard/global?period=weekly&limit=50
```

**Response:**
```json
{
  "success": true,
  "period": "weekly",
  "leaderboard": [
    {
      "userId": "user123",
      "username": "John Doe",
      "rank": 1,
      "points": 1250,
      "safetyScore": 92.5,
      "totalDistance": 234.5,
      "avatarUrl": "https://example.com/avatar.jpg"
    }
  ]
}
```

---

#### 2. Get Friends Leaderboard
Get leaderboard filtered to user's friends.

**Endpoint:** `GET /leaderboard/friends/:userId`

**Path Parameters:**
- `userId`: User ID

**Query Parameters:**
- `period` (optional): `weekly`, `monthly`, or `all_time` (default: `all_time`)

**Example Request:**
```bash
curl http://localhost:3000/api/leaderboard/friends/user123?period=weekly
```

**Response:**
```json
{
  "success": true,
  "period": "weekly",
  "leaderboard": [
    {
      "userId": "friend1",
      "username": "Jane Smith",
      "rank": 5,
      "friendRank": 1,
      "points": 890,
      "safetyScore": 88.0,
      "totalDistance": 156.2
    }
  ]
}
```

---

#### 3. Get Safety Leaderboard
Get leaderboard ranked by safety score.

**Endpoint:** `GET /leaderboard/safety`

**Query Parameters:**
- `limit` (optional): Number of entries (default: 100)

**Example Request:**
```bash
curl http://localhost:3000/api/leaderboard/safety?limit=20
```

**Response:**
```json
{
  "success": true,
  "leaderboard": [
    {
      "userId": "user456",
      "username": "Safety Pro",
      "safetyScore": 98.5,
      "rank": 1
    }
  ]
}
```

---

#### 4. Get Distance Leaderboard
Get leaderboard ranked by total distance.

**Endpoint:** `GET /leaderboard/distance`

**Query Parameters:**
- `limit` (optional): Number of entries (default: 100)

**Example Request:**
```bash
curl http://localhost:3000/api/leaderboard/distance?limit=20
```

**Response:**
```json
{
  "success": true,
  "leaderboard": [
    {
      "userId": "user789",
      "username": "Distance King",
      "totalDistance": 5432.1,
      "rank": 1
    }
  ]
}
```

---

#### 5. Get User Rank
Get a specific user's rank position.

**Endpoint:** `GET /users/:userId/rank`

**Path Parameters:**
- `userId`: User ID

**Query Parameters:**
- `period` (optional): `weekly`, `monthly`, or `all_time` (default: `all_time`)

**Example Request:**
```bash
curl http://localhost:3000/api/users/user123/rank?period=all_time
```

**Response:**
```json
{
  "success": true,
  "rank": 42,
  "points": 850,
  "totalUsers": 1523,
  "rankChange": 5
}
```

---

### Points Endpoints

#### 6. Get User Points
Get a user's points data.

**Endpoint:** `GET /points/:userId`

**Path Parameters:**
- `userId`: User ID

**Example Request:**
```bash
curl http://localhost:3000/api/points/user123
```

**Response:**
```json
{
  "success": true,
  "userId": "user123",
  "totalPoints": 1250,
  "dailyPoints": 45,
  "weeklyPoints": 320,
  "pointHistory": []
}
```

---

#### 7. Get Points History
Get a user's points transaction history.

**Endpoint:** `GET /points/:userId/history`

**Path Parameters:**
- `userId`: User ID

**Query Parameters:**
- `limit` (optional): Number of transactions (default: 50)

**Example Request:**
```bash
curl http://localhost:3000/api/points/user123/history?limit=20
```

**Response:**
```json
{
  "success": true,
  "history": [
    {
      "points": 10,
      "reason": "Completed ride",
      "activityType": "COMPLETE_RIDE",
      "multiplier": 1.0,
      "timestamp": "2024-01-15T10:30:00.000Z"
    },
    {
      "points": 22,
      "reason": "Safe weekend ride",
      "activityType": "SAFE_RIDE",
      "multiplier": 1.5,
      "timestamp": "2024-01-14T09:15:00.000Z"
    }
  ]
}
```

---

#### 8. Award Points
Award points to a user for an activity.

**Endpoint:** `POST /points/award`

**Request Body:**
```json
{
  "userId": "user123",
  "activityType": "COMPLETE_RIDE",
  "reason": "Completed morning ride"
}
```

**Activity Types:**
- `COMPLETE_RIDE` - +10 points
- `SAFE_RIDE` - +15 points
- `LONG_DISTANCE` - +20 points
- `CONSISTENT_RIDING` - +25 points
- `AI_COACHING` - +5 points
- `FRIEND_REFERRAL` - +50 points
- `STREAK_BONUS` - +30 points

**Example Request:**
```bash
curl -X POST http://localhost:3000/api/points/award \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "activityType": "COMPLETE_RIDE",
    "reason": "Completed morning ride"
  }'
```

**Response:**
```json
{
  "success": true,
  "points": 10,
  "message": "Awarded 10 points for Completed morning ride"
}
```

---

### Badge Endpoints

#### 9. Get All Badges
Get all available badges in the system.

**Endpoint:** `GET /badges/all`

**Example Request:**
```bash
curl http://localhost:3000/api/badges/all
```

**Response:**
```json
{
  "success": true,
  "badges": [
    {
      "id": "safe_rider",
      "badgeId": "safe_rider",
      "name": "Safe Rider",
      "description": "10 rides with 0 overspeeds",
      "icon": "🛡️",
      "criteria": {
        "rides_with_zero_overspeeds": 10
      }
    }
  ]
}
```

---

#### 10. Get User Badges
Get badges unlocked by a specific user.

**Endpoint:** `GET /badges/:userId`

**Path Parameters:**
- `userId`: User ID

**Example Request:**
```bash
curl http://localhost:3000/api/badges/user123
```

**Response:**
```json
{
  "success": true,
  "badges": [
    {
      "badgeId": "safe_rider",
      "name": "Safe Rider",
      "icon": "🛡️",
      "unlockedAt": "2024-01-10T14:20:00.000Z"
    }
  ]
}
```

---

#### 11. Get Badge Progress
Get a user's progress toward all badges.

**Endpoint:** `GET /badges/:userId/progress`

**Path Parameters:**
- `userId`: User ID

**Request Body:**
```json
{
  "userStats": {
    "totalRides": 15,
    "ridesWithZeroOverspeeds": 7,
    "totalDistanceKm": 234.5,
    "currentStreak": 5
  }
}
```

**Example Request:**
```bash
curl http://localhost:3000/api/badges/user123/progress \
  -H "Content-Type: application/json" \
  -d '{
    "userStats": {
      "totalRides": 15,
      "ridesWithZeroOverspeeds": 7
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "progress": [
    {
      "badgeId": "safe_rider",
      "name": "Safe Rider",
      "unlocked": false,
      "progress": 70.0
    }
  ]
}
```

---

#### 12. Unlock Badge
Check and unlock a badge for a user (admin endpoint).

**Endpoint:** `POST /badges/:userId/unlock`

**Path Parameters:**
- `userId`: User ID

**Request Body:**
```json
{
  "badgeId": "safe_rider",
  "userStats": {
    "ridesWithZeroOverspeeds": 10
  }
}
```

**Example Request:**
```bash
curl -X POST http://localhost:3000/api/badges/user123/unlock \
  -H "Content-Type: application/json" \
  -d '{
    "badgeId": "safe_rider",
    "userStats": {
      "ridesWithZeroOverspeeds": 10
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "badge": {
    "badgeId": "safe_rider",
    "name": "Safe Rider",
    "icon": "🛡️",
    "unlockedAt": "2024-01-15T10:30:00.000Z"
  },
  "message": "Badge \"Safe Rider\" unlocked!"
}
```

---

### Achievement Endpoints

#### 13. Get All Achievements
Get all available achievements.

**Endpoint:** `GET /achievements/all`

**Example Request:**
```bash
curl http://localhost:3000/api/achievements/all
```

**Response:**
```json
{
  "success": true,
  "achievements": [
    {
      "id": "rides_10",
      "achievementId": "rides_10",
      "name": "10 Rides",
      "description": "Complete 10 rides",
      "type": "milestone",
      "icon": "🎯",
      "milestone": 10
    }
  ]
}
```

---

#### 14. Get User Achievements
Get achievements unlocked by a user.

**Endpoint:** `GET /achievements/:userId`

**Path Parameters:**
- `userId`: User ID

**Example Request:**
```bash
curl http://localhost:3000/api/achievements/user123
```

**Response:**
```json
{
  "success": true,
  "achievements": [
    {
      "achievementId": "rides_10",
      "name": "10 Rides",
      "type": "milestone",
      "icon": "🎯",
      "unlockedAt": "2024-01-12T08:45:00.000Z"
    }
  ]
}
```

---

#### 15. Get Achievement Progress
Get user's progress toward all achievements.

**Endpoint:** `GET /achievements/:userId/progress`

**Path Parameters:**
- `userId`: User ID

**Request Body:**
```json
{
  "userStats": {
    "totalRides": 15,
    "totalDistanceKm": 234.5
  }
}
```

**Response:**
```json
{
  "success": true,
  "progress": [
    {
      "achievementId": "rides_10",
      "name": "10 Rides",
      "unlocked": true,
      "progress": 100.0
    },
    {
      "achievementId": "rides_50",
      "name": "50 Rides",
      "unlocked": false,
      "progress": 30.0
    }
  ]
}
```

---

## Error Responses

All endpoints return errors in the following format:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

**Common HTTP Status Codes:**
- `200` - Success
- `400` - Bad Request (missing parameters)
- `404` - Not Found
- `500` - Internal Server Error

## Rate Limiting

Currently no rate limiting is implemented. Consider adding rate limiting in production.

## Authentication

Currently no authentication is required. In production, add JWT or session-based authentication.
