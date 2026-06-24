# RiderMate Backend API

Backend API server for RiderMate - A cycling and ride tracking application with AI-powered features.

## Features

- **User Authentication**: Register and login with JWT tokens
- **Ride Tracking**: Start, pause, resume, and end rides with real-time location tracking
- **AI Analysis**: Powered by OpenAI GPT-4 for ride analysis and safety scoring
- **Memories**: Create and share riding memories with photos and locations
- **Social Features**: Friend requests and leaderboard
- **Chat Assistant**: AI-powered cycling assistant
- **Firebase Integration**: Cloud Firestore for data persistence

## Tech Stack

- **Runtime**: Node.js with TypeScript
- **Framework**: Express.js
- **Database**: Firebase Firestore
- **AI**: OpenAI GPT-4
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: Helmet, bcryptjs
- **Logging**: Morgan

## Prerequisites

- Node.js 18+ and npm
- Firebase project with Firestore enabled
- OpenAI API key

## Installation

1. Clone the repository:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file from `.env.example`:
```bash
cp .env.example .env
```

4. Configure environment variables in `.env`:
```env
PORT=3000
NODE_ENV=development

# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email

# Or use service account file
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json

# OpenAI Configuration
OPENAI_API_KEY=your-openai-api-key
OPENAI_MODEL=gpt-4

# JWT Configuration
JWT_SECRET=your-jwt-secret-key-change-this-in-production
JWT_EXPIRES_IN=7d

# CORS Configuration
CORS_ORIGIN=http://localhost:3001,http://localhost:8080
```

5. (Optional) Download Firebase service account JSON and place it in the backend directory.

## Running the Server

### Development Mode
```bash
npm run dev
```

### Production Build
```bash
npm run build
npm start
```

## API Endpoints

### Health Check

#### `GET /health`
Check if the API is running.

**Response:**
```json
{
  "success": true,
  "message": "RiderMate API is running",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "environment": "development"
}
```

---

### Authentication

#### `POST /api/auth/register`
Register a new user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "securePassword123",
  "fullName": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "user123",
      "email": "user@example.com",
      "username": "johndoe",
      "profile": {
        "fullName": "John Doe"
      },
      "stats": {
        "totalRides": 0,
        "totalDistance": 0,
        "totalDuration": 0,
        "averageSpeed": 0
      }
    }
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### `POST /api/auth/login`
Login an existing user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": { ... }
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

### Rides

All ride endpoints require authentication. Include the JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

#### `POST /api/rides/start`
Start a new ride.

**Request Body:**
```json
{
  "startLocation": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "speed": 0,
    "altitude": 10
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "ride123",
    "userId": "user123",
    "startTime": "2024-01-01T10:00:00.000Z",
    "status": "active",
    "route": [
      {
        "latitude": 40.7128,
        "longitude": -74.0060,
        "timestamp": "2024-01-01T10:00:00.000Z",
        "speed": 0,
        "altitude": 10
      }
    ],
    "stats": {
      "distance": 0,
      "duration": 0,
      "averageSpeed": 0,
      "maxSpeed": 0,
      "elevationGain": 0
    }
  },
  "timestamp": "2024-01-01T10:00:00.000Z"
}
```

#### `POST /api/rides/end`
End an active ride.

**Request Body:**
```json
{
  "rideId": "ride123",
  "endLocation": {
    "latitude": 40.7580,
    "longitude": -73.9855,
    "speed": 2.5,
    "altitude": 12
  }
}
```

#### `POST /api/rides/pause`
Pause an active ride.

**Request Body:**
```json
{
  "rideId": "ride123"
}
```

#### `POST /api/rides/resume`
Resume a paused ride.

**Request Body:**
```json
{
  "rideId": "ride123"
}
```

#### `GET /api/rides/:rideId`
Get details of a specific ride.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "ride123",
    "userId": "user123",
    "startTime": "2024-01-01T10:00:00.000Z",
    "endTime": "2024-01-01T11:30:00.000Z",
    "status": "completed",
    "route": [...],
    "stats": {
      "distance": 15000,
      "duration": 5400,
      "averageSpeed": 2.78,
      "maxSpeed": 8.33,
      "elevationGain": 150
    },
    "aiAnalysis": {
      "safetyScore": 85,
      "insights": [...],
      "suggestions": [...]
    }
  },
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

#### `GET /api/rides/user/:userId`
Get all rides for a specific user.

**Query Parameters:**
- `limit` (optional): Number of rides to return (default: 50)

**Response:**
```json
{
  "success": true,
  "data": [
    { /* ride object */ },
    { /* ride object */ }
  ],
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

---

### AI Features

#### `POST /api/ai/analyze-ride`
Analyze a ride using AI for insights and safety scoring.

**Request Body:**
```json
{
  "rideId": "ride123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "rideId": "ride123",
    "analysis": {
      "safetyScore": 85,
      "insights": [
        "Great consistent pace throughout the ride",
        "Good elevation management on the climbs",
        "Route includes scenic areas"
      ],
      "suggestions": [
        "Consider taking more breaks on longer rides",
        "Try varying your route for different challenges",
        "Maintain steady cadence on descents"
      ],
      "analyzedAt": "2024-01-01T12:00:00.000Z"
    }
  },
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

#### `POST /api/ai/chat`
Chat with the AI cycling assistant.

**Request Body:**
```json
{
  "message": "What's the best way to improve my climbing speed?",
  "conversationHistory": [
    {
      "role": "user",
      "content": "Previous message"
    },
    {
      "role": "assistant",
      "content": "Previous response"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "To improve your climbing speed, focus on building leg strength through hill repeats...",
    "role": "assistant"
  },
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

---

### Memories

#### `POST /api/memories`
Create a new memory.

**Request Body:**
```json
{
  "rideId": "ride123",
  "title": "Epic Mountain Ride",
  "description": "Amazing ride through the mountains with great views",
  "photos": ["https://example.com/photo1.jpg"],
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "name": "Central Park"
  },
  "tags": ["mountain", "scenic", "challenging"],
  "isPublic": true
}
```

#### `GET /api/memories/:userId`
Get memories for a user.

**Query Parameters:**
- `limit` (optional): Number of memories to return (default: 50)

---

### Friends

#### `POST /api/friends/request`
Send a friend request.

**Request Body:**
```json
{
  "friendId": "user456"
}
```

#### `GET /api/friends/:userId`
Get friends for a user.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "friend123",
      "userId": "user123",
      "friendId": "user456",
      "status": "accepted",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

---

### Leaderboard

#### `GET /api/leaderboard`
Get the global leaderboard.

**Query Parameters:**
- `limit` (optional): Number of entries to return (default: 10)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "userId": "user123",
      "username": "johndoe",
      "avatar": "https://example.com/avatar.jpg",
      "totalDistance": 150000,
      "totalRides": 45,
      "rank": 1
    }
  ],
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

---

## Error Handling

All errors follow this format:

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE",
    "details": { /* Additional error details */ }
  },
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### Common Error Codes

- `UNAUTHORIZED` (401): Missing or invalid authentication token
- `VALIDATION_ERROR` (400): Invalid request data
- `NOT_FOUND` (404): Resource not found
- `EMAIL_EXISTS` (400): Email already registered
- `INVALID_CREDENTIALS` (401): Invalid email or password
- `INTERNAL_ERROR` (500): Server error

## Security

- All passwords are hashed using bcryptjs
- JWT tokens are used for authentication
- Helmet is used for security headers
- CORS is configured to allow only specified origins
- Input validation on all endpoints

## Development

### Project Structure

```
backend/
├── src/
│   ├── config/           # Configuration files
│   │   ├── firebase.config.ts
│   │   ├── openai.config.ts
│   │   └── server.config.ts
│   ├── controllers/      # Request handlers
│   │   ├── auth.controller.ts
│   │   ├── rides.controller.ts
│   │   ├── ai.controller.ts
│   │   ├── memories.controller.ts
│   │   ├── friends.controller.ts
│   │   └── leaderboard.controller.ts
│   ├── middleware/       # Express middleware
│   │   ├── auth.middleware.ts
│   │   └── error.middleware.ts
│   ├── routes/          # API routes
│   │   ├── auth.routes.ts
│   │   ├── rides.routes.ts
│   │   ├── ai.routes.ts
│   │   ├── memories.routes.ts
│   │   ├── friends.routes.ts
│   │   └── leaderboard.routes.ts
│   ├── services/        # Business logic
│   │   ├── auth.service.ts
│   │   ├── firebase.service.ts
│   │   └── openai.service.ts
│   ├── types/           # TypeScript types
│   │   ├── user.types.ts
│   │   ├── ride.types.ts
│   │   ├── other.types.ts
│   │   └── api.types.ts
│   └── index.ts         # Entry point
├── .env.example
├── .gitignore
├── package.json
├── tsconfig.json
└── README.md
```

### Scripts

- `npm run dev` - Run in development mode with auto-reload
- `npm run build` - Build for production
- `npm start` - Run production build
- `npm run lint` - Lint code
- `npm run format` - Format code with Prettier

## License

MIT

## Support

For issues and questions, please open an issue on GitHub.
